# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils unpacker patches

DESCRIPTION="Mozilla-compatible crypto-provider browser plugin for http://gosuslugi.ru/"

SRC_URI="
	amd64? ( https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib/IFCPlugin-x86_64.deb -> ${P}_amd64.deb )
	x86? ( https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib/IFCPlugin-i386.deb -> ${P}_x86.deb )
	x86-macos? ( https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib/IFCPlugin.pkg -> ${P}_mac.pkg )
	x64-macos? ( https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib/IFCPlugin.pkg -> ${P}_mac.pkg )
"
#	x86-winnt? ( https://ds-plugin.gosuslugi.ru/plugin/htdocs/plugin/IFCPlugin.msi )
#	x64-winnt? ( https://ds-plugin.gosuslugi.ru/plugin/htdocs/plugin/IFCPlugin-x64.msi )

HOMEPAGE="http://gosuslugi.ru/"
LICENSE="EULA"
RESTRICT="mirror"
SLOT="0"
KEYWORDS="~amd64 ~x86 x64-macos x86-macos"
IUSE="multilib"

REQUIRED_USE="amd64? ( multilib )"

# TODO: minimal useflag (I can't do it now, since
# it seems like I brake my token and it is uninitialized now)
RDEPEND="
	>=sys-apps/pcsc-lite-1.7
	>=app-crypt/asedriveiiie-usb-3.7
	virtual/libusb:0
	media-libs/hal-flash
"
DEPEND="${RDEPEND}"

QA_PREBUILT="*"
QA_SONAME_NO_SYMLINK="usr/lib32/.* usr/lib64/.*"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	insinto /
	doins -r usr etc
}
