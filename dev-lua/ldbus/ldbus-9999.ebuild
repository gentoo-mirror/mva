# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua{5-{1..4},jit} )

inherit lua git-r3 toolchain-funcs

DESCRIPTION="A Lua library to access dbus"
HOMEPAGE="https://github.com/daurnimator/ldbus/"
EGIT_REPO_URI="https://github.com/daurnimator/ldbus/"

LICENSE="MIT"
SLOT="0"
IUSE="examples"
REQUIRED_USE="${LUA_REQUIRED_USE}"

RDEPEND="
	${LUA_DEPS}
	sys-apps/dbus
"
DEPEND="
	${RDEPEND}
"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	cp "${FILESDIR}/GNUmakefile" "${S}/"
	sed -r \
		-e "/^PKG_CONFIG/{s@=.*@= $(tc-getPKG_CONFIG)@}" \
		-e '/install:/,${s@(\$\(LUA_LIBDIR\))@$(DESTDIR)/\1@g}' \
		-i src/Makefile || die
	lua_copy_sources
	lua_foreach_impl each_lua_prepare
}

each_lua_prepare() {
	pushd "${BUILD_DIR}"
	sed -r \
		-e "/^LUA_PKGNAME/{s@=.*@= ${ELUA}@}" \
		-e "/^LUA_LIBDIR/{s@=.*@= $(lua_get_cmod_dir)@}" \
		-i src/Makefile || die
	popd
}

each_lua_compile() {
	pushd "${BUILD_DIR}"
	default
	popd
}

each_lua_install() {
	pushd "${BUILD_DIR}"
	insinto "$(lua_get_lmod_dir)"
	doins -r src/message
	insinto "$(lua_get_cmod_dir)"
	doins src/"${PN}".so
	popd
}

src_compile() {
	lua_foreach_impl each_lua_compile
}

src_install() {
	lua_foreach_impl each_lua_install
	if use examples; then
		mkdir -p examples &&
		mv example.lua examples
		DOCS+=(examples)
		docompress -x "/usr/share/doc/${PF}/examples"
	fi
	einstalldocs
}
