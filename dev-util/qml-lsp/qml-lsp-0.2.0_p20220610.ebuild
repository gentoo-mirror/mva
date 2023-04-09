# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

MY_COMMIT="19c7deccfc2d4f4ea0d6d7e94dc75088d2612727"

DESCRIPTION="Collection of QML tools, including qml-lsp, qml-dap, and qml-refactor-fairy"
HOMEPAGE="https://invent.kde.org/sdk/qml-lsp"
SRC_URI="
	https://invent.kde.org/sdk/${PN}/-/archive/${MY_COMMIT}/${PN}-${MY_COMMIT}.tar.bz2
	https://tastytea.de/files/gentoo/${P}-vendor.tar.xz
"
S="${WORKDIR}/${PN}-${MY_COMMIT}"

# NOTE: Generate vendor tarball like this:
#       go mod vendor && cd ..
#       tar -caf ${P}-vendor.tar.xz qml-lsp-rjienrlwey-*/vendor

LICENSE="Apache-2.0 GPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-libs/tree-sitter"
RDEPEND="
	${DEPEND}
	dev-qt/qtcore
"
BDEPEND=""

PATCHES=( "${FILESDIR}"/${PN}-0.2.0-find-qmake5.patch )

src_compile() {
	# TODO: get qml-{dap,dbg} to compile
	for cmd in ./cmd/qml-{doxygen,lint,lsp,refactor-fairy}; do
		ego build -ldflags '-linkmode external' ${cmd}
	done
}

src_test() {
	# NOTE: check for more tests on next release
	ego test ./qmltypes ./analysis
}

src_install() {
	dobin qml-{doxygen,lint,lsp,refactor-fairy}
	einstalldocs
}
