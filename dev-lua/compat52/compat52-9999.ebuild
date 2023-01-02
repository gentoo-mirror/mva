# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua{5-1,jit} )

inherit lua git-r3

DESCRIPTION="Compatibility module providing Lua-5.2-style APIs for Lua 5.1"
HOMEPAGE="https://github.com/keplerproject/lua-compat-5.2"
EGIT_REPO_URI="https://github.com/keplerproject/lua-compat-5.2"

LICENSE="MIT"
SLOT="0"
REQUIRED_USE="${LUA_REQUIRED_USE}"
RDEPEND="
	${LUA_DEPS}
	dev-lua/lua-bit32[${LUA_USEDEP}]
"
DEPEND="
	${RDEPEND}
"

each_lua_install() {
	insinto "$(lua_get_lmod_dir)"
	doins -r "${PN}" "${PN}.lua"
}

src_install() {
	lua_foreach_impl each_lua_install
	einstalldocs
}
