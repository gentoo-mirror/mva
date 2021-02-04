# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=TOKUHIROM
inherit perl-module

DESCRIPTION="Binding library for hoedown"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="
	${RDEPEND}
	dev-perl/File-pushd
	dev-perl/Module-Build
"
