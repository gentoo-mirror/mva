# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils multilib-minimal

DESCRIPTION="A non-backtracking regex engine matching on data streams"
HOMEPAGE="https://github.com/openresty/sregex"
SRC_URI=""

SRC_URI="https://github.com/openresty/${PN}/archive/v${PV//_}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

S="${WORKDIR}/${P//_}"

src_prepare() {
	sed -r \
		-e '/^PREFIX=/s@(PREFIX)=.*@\1=/usr@' \
		-e '/^INSTALL_LIB/s@lib@$(LIBDIR_${ABI})@' \
		-i Makefile
	default
	multilib_copy_sources
}
