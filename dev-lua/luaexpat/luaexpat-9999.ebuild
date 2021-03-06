# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VCS="mercurial"
IS_MULTILIB=true

inherit lua

DESCRIPTION="SAX XML parser based on the Expat library."
HOMEPAGE="http://code.matthewwild.co.uk/"
EHG_REPO_URI="http://code.matthewwild.co.uk/lua-expat/"
#EHG_REPO_URI="https://bitbucket.org/mva/luaexpat-temp"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="doc"

RDEPEND="
	dev-libs/expat
"
DEPEND="
	${RDEPEND}
"

DOCS=(README)
HTML_DOCS=(doc/.)

all_lua_prepare() {
	sed -i -r \
		-e '/^COMMON_CFLAGS/s# -ansi##' \
		Makefile

	sed -i -r \
		-e 's@static (void luaL_setfuncs)@LUALIB_API \1@' \
		src/lxplib.c

	lua_default
}

each_lua_configure() {
	myeconfargs=(
		LUA_V="${lua_impl##lua}"
	)
	lua_default
}

each_lua_install() {
	dolua src/lxp{,.so}
}
