# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VIRTUALX_REQUIRED="manual"
LUA_COMPAT=( lua{5-{1..4},jit} )

inherit lua git-r3 toolchain-funcs virtualx

DESCRIPTION="Dynamic Lua binding to GObject libraries using GObject-Introspection"
HOMEPAGE="https://github.com/lgi-devs/lgi"
EGIT_REPO_URI="https://github.com/lgi-devs/lgi"

LICENSE="MIT"
SLOT="0"
IUSE="examples test"
RESTRICT="!test? ( test )"
REQUIRED_USE="${LUA_REQUIRED_USE}"

BDEPEND="${LUA_DEPS}"
RDEPEND="
	${LUA_DEPS}
	dev-libs/glib
	dev-libs/gobject-introspection
	dev-libs/libffi:0=
"
DEPEND="
	${RDEPEND}
	test? (
		x11-libs/cairo[glib]
		x11-libs/gtk+[introspection]
		${VIRTUALX_DEPEND}
	)
"

DOCS+=(docs)

lua_src_prepare() {
	pushd "${BUILD_DIR}" || die
	# The Makefile & several source files use the LUA version as part of the
	# direct filename, dynamically created, and we respect that.
	_slug=${ELUA}
	_slug=${_slug/.}
	_slug=${_slug/-}
	_slug=${_slug/_}

	# Makefile: CORE = corelgilua51.so (and similar lines)
	sed -r -i \
		-e "/^CORE\>/s,lua5.,${_slug},g" \
		lgi/Makefile \
		|| die "sed failed"

	# ./lgi/core.lua:local core = require 'lgi.corelgilua51'
	# ./lgi/core.c:luaopen_lgi_corelgilua51 (lua_State* L)
	sed -r -i \
		-e "/lgi.corelgilua5./s,lua5.,${_slug},g" \
		lgi/core.lua \
		lgi/core.c \
		|| die "sed failed"

	# Verify the change as it's important!
	for f in lgi/core.lua lgi/core.c lgi/Makefile ; do
		grep -sq "corelgi${_slug}" "${f}" || die "Failed to sed .lua & .c for corelgi${_slug}: ${f}"
	done

	# Cleanup
	unset _slug
	popd
}

src_prepare() {
	default
	lua_copy_sources
	lua_foreach_impl lua_src_prepare
}

lgi_emake_wrapper() {
	emake \
	CC="$(tc-getCC)" \
	COPTFLAGS="-Wall -Wextra ${CFLAGS}" \
	LIBFLAG="-shared ${LDFLAGS}" \
	LUA_CFLAGS="$(lua_get_CFLAGS)" \
	LUA="${LUA}" \
	LUA_VERSION="${ELUA#lua}" \
	LUA_LIBDIR="$(lua_get_cmod_dir)" \
	LUA_SHAREDIR="$(lua_get_lmod_dir)" \
	"$@"
}

lua_src_compile() {
	pushd "${BUILD_DIR}" || die
	lgi_emake_wrapper all
	popd
}

src_compile() {
	lua_foreach_impl lua_src_compile
}

lua_src_test() {
	pushd "${BUILD_DIR}" || die
	virtx \
		lgi_emake_wrapper \
		check
	popd
}

src_test() {
	lua_foreach_impl lua_src_test
}

lua_src_install() {
	pushd "${BUILD_DIR}" || die
	lgi_emake_wrapper \
		DESTDIR="${D}" \
		install
	popd
}

src_install() {
	lua_foreach_impl lua_src_install
	if use examples; then
		docompress -x /usr/share/doc/${PF}/samples
		DOCS+=(samples)
	fi
	einstalldocs
}
