# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/F1ash/qt-virt-manager.git"
	EGIT_BRANCH="master"
	inherit git-r3
else
	SRC_URI="https://github.com/F1ash/qt-virt-manager/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

DESCRIPTION="A GUI application for managing virtual machines"
HOMEPAGE="https://github.com/F1ash/qt-virt-manager"

LICENSE="GPL-2"
SLOT="0"
IUSE="smartcard"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	dev-qt/qtnetwork:5
	>=x11-libs/qtermwidget-0.7.0
	smartcard? ( >=app-emulation/libcacard-2.5.0 )
	dev-libs/glib
	net-misc/spice-gtk
	app-emulation/spice-protocol
	net-libs/libvncserver
	app-emulation/libvirt
	kde-apps/krdc
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_QT_VERSION=5
		-DWITH_LIBCACARD="$(usex smartcard ON OFF)"
	)
	cmake_src_configure
}
