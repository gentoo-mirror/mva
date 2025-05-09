# Copyright 2025 mva
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit readme.gentoo-r1 systemd patches shell-completion

DESCRIPTION="Scripts to support compressed swap devices or ramdisks with zram"
HOMEPAGE="https://github.com/vaeth/zram-init/"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vaeth/${PN}"
else
	SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~x86"
fi

LICENSE="GPL-2"
SLOT="0"

RDEPEND="
	app-shells/push
	sys-apps/openrc
"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="To use zram, activate it in your kernel and add it to default runlevel:
	rc-config add zram default
If you use systemd enable zram_swap, tmp, and/or var_tmp with systemctl.
You might need to modify /etc/modprobe.d/zram.conf"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- sbin/* || die
	default
}

src_install() {
	doinitd openrc/init.d/*
	doconfd openrc/conf.d/*
	systemd_dounit systemd/system/*
	insinto /etc/modprobe.d
	doins modprobe.d/*
	dozshcomp zsh/*
	dodoc AUTHORS ChangeLog README.md
	readme.gentoo_create_doc
	into /
	dosbin sbin/*
}

pkg_postinst() {
	readme.gentoo_print_elog
}
