# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="A game prototype by Maurice (mari0 author)"
HOMEPAGE="http://stabyourself.net/other/"
SRC_URI="http://stabyourself.net/dl.php?file=${PN}/${PN}.love -> ${P}.zip"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""
RESTRICT=""

DEPEND=">=games-engines/love-0.8.0:*"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	local dir="/usr/share/games/love/${PN}"
	insinto "${dir}"
	doins -r .
	make_wrapper "${PN}" "love /usr/share/games/love/${PN}"
	make_desktop_entry "${PN}"
}

pkg_postinst() {
	elog "${PN} savegames and configurations are stored in:"
	elog "~/.local/share/love/${PN}/"
}
