# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper

MY_PN=SuperMeatBoy
MY_PV=$(ver_cut 2)$(ver_cut 3)$(ver_cut 1)

DESCRIPTION="A platformer where you play as an animated cube of meat"
HOMEPAGE="http://www.supermeatboy.com/"
SRC_URI="${PN}-linux-${MY_PV}-bin"

S="${WORKDIR}/data"
GAMEDIR="/usr/share/${P}"

LICENSE="GOG-EULA"
# TODO: find proper license
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

RESTRICT="fetch bindist"

RDEPEND="
	media-libs/openal
	media-libs/libsdl2
"
BDEPEND="app-arch/zip"

pkg_nofetch() {
	einfo "Please download ${A}"
	einfo "from your library in Humble Indie Bundle site"
	einfo "(http://www.humblebundle.com)"
	einfo "and place it to ${DESTDIR}"
}

src_unpack() {
	# self unpacking zip archive; unzip warns about the exe stuff
	# (taken from lugaru ebuild)
	local a=${DISTDIR}/${A}
	echo ">>> Unpacking ${A} to ${PWD}"
	unzip -q "${a}"
	[ $? -gt 1 ] && die "unpacking failed"
}

src_install() {
	insinto "${GAMEDIR}"
	doins -r resources Levels buttonmap.cfg \
		gameaudio.dat gamedata.dat locdb.txt \
		steam_appid.txt

	insinto "${GAMEDIR}/${ARCH}"
	doins "${ARCH}"/libsteam_api.so

	# use system-mariadb &&
	# dosym /usr/lib64/mariadb/libmariadb.so "${GAMEDIR}/${ARCH}"/libmariadb.so.1 ||
	doins "${ARCH}"/libmariadb.so.1

	exeinto "${GAMEDIR}/${ARCH}"
	doexe "${ARCH}/${MY_PN}"

	make_wrapper "${PN}" "./${ARCH}/${MY_PN}" "${GAMEDIR}" "./${ARCH}"

	doicon "${PN}".png
	make_desktop_entry "${PN}" "${MY_PN}" "${PN}"

	dodoc README-linux.txt
}
