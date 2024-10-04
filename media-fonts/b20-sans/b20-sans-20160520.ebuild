# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="B20 Sans, a sans-serif font"
HOMEPAGE="https://www.dafont.com/b20-sans.font"

SRC_URI="https://img.dafont.com/dl/?f=b20_sans -> ${P}.zip"
S="${WORKDIR}"

inherit font

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~s390 ~sparc ~x86"

BDEPEND="app-arch/unzip"

RESTRICT="strip binchecks"

FONT_SUFFIX="ttf"
