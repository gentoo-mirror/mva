# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A POSIX shell function to treat a variable like an array, quoting args"
HOMEPAGE="https://github.com/vaeth/push/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

IUSE="split-usr"

# Install into / to let sys-block/zram-init work with split /usr

src_compile() {
	emake PREFIX= EPREFIX="${EPREFIX}" BINDIR=$(get_usr)/bin DATADIR=$(get_usr)/lib/push
}

src_install() {
	dodoc README.md
	emake DESTDIR="${ED}" PREFIX= EPREFIX="${EPREFIX}" BINDIR="$(get_usr)/bin" DATADIR="$(get_usr)/lib/push" install
	dosym "$(get_usr)/lib/${PN}" "/usr/share/${PN}"
}

get_usr() {
	use split-usr || echo /usr
}
