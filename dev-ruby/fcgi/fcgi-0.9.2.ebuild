# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#

EAPI="5"
USE_RUBY="ruby18 ruby19 ree18 jruby ruby20"

RUBY_FAKEGEM_EXTRADOC="README.rdoc README.signals"

inherit multilib ruby-fakegem

DESCRIPTION="FastCGI library for Ruby"
HOMEPAGE="https://rubygems.org/gems/fcgi/"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
LICENSE="MIT"

DEPEND+=" dev-libs/fcgi"
RDEPEND+=" dev-libs/fcgi"

IUSE=""
SLOT="0"

each_ruby_configure() {
	case ${RUBY} in
		*ruby18|*ruby19|*rubyee18|*ruby20)
			${RUBY} -C ext/fcgi extconf.rb || die "extconf failed"
			;;
	esac
}

each_ruby_compile() {
	case ${RUBY} in
		*ruby18|*ruby19|*rubyee18|*ruby20)
			emake -C ext/fcgi
			cp ext/fcgi/fcgi$(get_modname) lib || die "compile failed"
			;;
	esac
}
