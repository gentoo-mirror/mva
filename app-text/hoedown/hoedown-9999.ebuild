# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3 multilib-minimal

DESCRIPTION="Standards compliant, fast, secure markdown processing library in C"
EGIT_REPO_URI="https://github.com/hoedown/hoedown"

HOMEPAGE="https://github.com/hoedown/hoedown"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	dev-util/gperf
"
RDEPEND=""

src_prepare() {
	sed -r \
		-e '/^PREFIX/s@(=).*@\1/usr@' \
		-i Makefile

	default
	multilib_copy_sources
}
