# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua{5-{1..4},jit} )

inherit lua git-r3

DESCRIPTION="Pure Lua Random Generator"
HOMEPAGE="https://github.com/linux-man/randomlua"
EGIT_REPO_URI="https://github.com/linux-man/randomlua"

LICENSE="MIT"
SLOT="0"
REQUIRED_USE="${LUA_REQUIRED_USE}"
RDEPEND="${LUA_DEPS}"
DEPEND="${RDEPEND}"

each_lua_install() {
	insinto "$(lua_get_lmod_dir)"
	doins "${PN}.lua"
}

src_install() {
	lua_foreach_impl each_lua_install
	einstalldocs
}
