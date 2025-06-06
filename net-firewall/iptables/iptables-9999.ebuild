# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Force users doing their own patches to install their own tools
AUTOTOOLS_AUTO_DEPEND=no

inherit systemd autotools toolchain-funcs flag-o-matic git-r3
# usr-ldscript

DESCRIPTION="Linux kernel (2.4+) firewall, NAT and packet mangling tools"
HOMEPAGE="https://netfilter.org/projects/iptables/"
EGIT_REPO_URI="https://git.netfilter.org/iptables"

LICENSE="GPL-2"
# Subslot tracks libxtables as that's the one other packages generally link
# against and iptables changes.  Will have to revisit if other sonames change.
SLOT="0/11"
IUSE="conntrack ipq ipv6 netlink nftables pcap static-libs"

COMMON_DEPEND="
	conntrack? ( >=net-libs/libnetfilter_conntrack-1.0.6 )
	netlink? ( net-libs/libnfnetlink )
	nftables? (
		>=net-libs/libmnl-1.0:=
		>=net-libs/libnftnl-1.2.6:=
	)
	pcap? ( net-libs/libpcap )
"

DEPEND="
	${COMMON_DEPEND}
	virtual/os-headers
	>=sys-kernel/linux-headers-4.4:0
"

BDEPEND="
	virtual/pkgconfig
	nftables? (
		app-alternatives/lex
		app-alternatives/yacc
	)
"

RDEPEND="
	${COMMON_DEPEND}
	nftables? ( net-misc/ethertypes )
"
# NOTE: 👇 nonexistent blocker RDEPEND="...": no matches in repo history
# 	!<net-firewall/ebtables-2.0.11-r1
# 	!<net-firewall/arptables-0.0.5-r1

IDEPEND=">=app-eselect/eselect-iptables-20220320"

PATCHES=(
	"${FILESDIR}"/${PN}-1.8.4-no-symlinks.patch
)

src_prepare() {
	# use the saner headers from the kernel
	rm -f include/linux/{kernel,types}.h

	default
	eautoreconf
}

src_configure() {
	# Some libs use $(AR) rather than libtool to build #444282
	tc-export AR

	# Hack around struct mismatches between userland & kernel for some ABIs. #472388
	use amd64 && [[ ${ABI} == "x32" ]] && append-flags -fpack-struct

	# sed -i \
	# 	-e "/nfnetlink=[01]/s:=[01]:=$(usex netlink 1 0):" \
	# 	-e "/nfconntrack=[01]/s:=[01]:=$(usex conntrack 1 0):" \
	# 	configure || die

	local myeconfargs=(
		--sbindir="${EPREFIX}/sbin"
		--libexecdir="${EPREFIX}/$(get_libdir)"
		--enable-devel
		--enable-shared
		$(use_enable conntrack connlabel)
		$(use_enable nftables)
		$(use_enable netlink libnfnetlink)
		$(use_enable pcap bpf-compiler)
		$(use_enable pcap nfsynproxy)
		$(use_enable static-libs static)
		$(use_enable ipq)
		$(use_enable ipv6)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	# Deal with parallel build errors.
	# use nftables && emake -C iptables xtables-config-parser.h
	emake V=1
}

src_install() {
	default

	# Managed by eselect-iptables
	# https://bugs.gentoo.org/881295
	rm "${ED}/usr/bin/iptables-xml" || die

	dodoc iptables/iptables.xslt

	# all the iptables binaries are in /sbin, so might as well
	# put these small files in with them
	into /
	dosbin iptables/iptables-apply
	dosym iptables-apply /sbin/ip6tables-apply
	doman iptables/iptables-apply.8

	insinto /usr/include
	doins include/iptables.h $(use ipv6 && echo include/ip6tables.h)
	insinto /usr/include/iptables
	doins include/iptables/internal.h

	keepdir /var/lib/iptables
	newinitd "${FILESDIR}"/${PN}.init iptables
	newconfd "${FILESDIR}"/${PN}-1.4.13.confd iptables
	if use ipv6 ; then
		keepdir /var/lib/ip6tables
		newinitd "${FILESDIR}"/iptables.init ip6tables
		newconfd "${FILESDIR}"/ip6tables-1.4.13.confd ip6tables
	fi

	if use nftables; then
		# Bug #647458
		rm "${ED}"/etc/ethertypes || die

		# Bugs #660886 and #669894
		rm "${ED}"/sbin/{arptables,ebtables}{,-{save,restore}} || die
	fi

	systemd_dounit "${FILESDIR}"/systemd/iptables{,-{re,}store}.service
	if use ipv6 ; then
		systemd_dounit "${FILESDIR}"/systemd/ip6tables{,-{re,}store}.service
	fi

	# # Move important libs to /lib #332175
	# gen_usr_ldscript -a ip{4,6}tc iptc xtables

	find "${ED}" -type f -name "*.la" -delete || die
}

pkg_postinst() {
	local default_iptables="xtables-legacy-multi"
	if ! eselect iptables show &>/dev/null; then
		elog "Current iptables implementation is unset, setting to ${default_iptables}"
		eselect iptables set "${default_iptables}"
	fi

	if use nftables; then
		local tables
		for tables in {arp,eb}tables; do
			if ! eselect ${tables} show &>/dev/null; then
				elog "Current ${tables} implementation is unset, setting to ${default_iptables}"
				eselect ${tables} set xtables-nft-multi
			fi
		done
	fi

	eselect iptables show
}

pkg_prerm() {
	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		elog "Unsetting iptables symlinks before removal"
		eselect iptables unset
	fi

	if ! has_version 'net-firewall/ebtables'; then
		elog "Unsetting ebtables symlinks before removal"
		eselect ebtables unset
	elif [[ -z ${REPLACED_BY_VERSION} ]]; then
		elog "Resetting ebtables symlinks to ebtables-legacy"
		eselect ebtables set ebtables-legacy
	fi

	if ! has_version 'net-firewall/arptables'; then
		elog "Unsetting arptables symlinks before removal"
		eselect arptables unset
	elif [[ -z ${REPLACED_BY_VERSION} ]]; then
		elog "Resetting arptables symlinks to arptables-legacy"
		eselect arptables set arptables-legacy
	fi

	# The eselect module failing should not be fatal
	return 0
}
