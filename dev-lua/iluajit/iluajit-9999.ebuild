# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LUA_COMPAT=( luajit )

inherit lua git-r3

DESCRIPTION="Readline powered shell for LuaJIT"
HOMEPAGE="https://github.com/jdesgats/ILuaJIT"
EGIT_REPO_URI="https://github.com/jdesgats/ILuaJIT"


LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="doc +completion"

RDEPEND="
	doc? ( dev-lua/luadoc )
	dev-lua/penlight
	sys-libs/readline:0
	completion? ( dev-lua/luafilesystem )
"
DEPEND="${RDEPEND}"

DOCS=(README.md)

src_prepare() {
	use doc && {
		luadoc . -d html
		export HTML_DOCS=(html/.)
	}
	default
	lua_copy_sources
}

lua_src_install() {
	insinto $(lua_get_lmod_dir)
	doins *.lua
}

src_install() {
	lua_foreach_impl lua_src_install
	dobin "${FILESDIR}/${PN}"
	einstalldocs
}
