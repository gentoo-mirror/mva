# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VCS="git"
GITHUB_A="openresty"
GITHUB_PN="lua-${PN}"

inherit lua-broken

DESCRIPTION="Streaming reader and parser for HTTP file uploading based on ngx_lua cosocket"
HOMEPAGE="https://github.com/openresty/lua-resty-upload"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	www-servers/nginx:*[nginx_modules_http_lua]
"
DEPEND="
	${RDEPEND}
"

DOCS=(README.markdown)

each_lua_install() {
	dolua lib/resty
}
