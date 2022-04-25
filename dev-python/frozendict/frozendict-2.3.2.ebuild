# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8,9,10} )

inherit distutils-r1

DESCRIPTION="A simple immutable mapping for python"
HOMEPAGE="https://github.com/Marco-Sulla/python-frozendict"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

BDEPEND="
	${PYTHON_DEPS}
	${DISTUTIL_DEPS}
"
RDEPEND="${PYTHON_DEPS}"