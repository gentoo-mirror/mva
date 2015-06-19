# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from mva overlay; $

EAPI="5"

# This package really only does anything meaningful for ruby 1.8, but
# other packages may depend on it unconditionally so we add their
# targets as well and install a no-op file.
USE_RUBY="ruby19 ruby20"

RUBY_FAKEGEM_TASK_DOC="docs"
RUBY_FAKEGEM_TASK_TEST="test"

RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="CHANGELOG"

inherit ruby-fakegem multilib

DESCRIPTION="Optimized replacement for thread.rb primitives"
HOMEPAGE="http://gemcutter.org/gems/fastthread"

LICENSE="Ruby"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ppc ppc64 ~sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

ruby_add_bdepend "doc? ( >=dev-ruby/echoe-2.7.1 )"

all_ruby_prepare() {
	sed -i -e 's|if Platform|if Echoe::Platform|' Rakefile || die
	mkdir lib || die
}

each_ruby_configure() {
	${RUBY} -Cext/fastthread extconf.rb || die
}

each_ruby_compile() {
	case ${RUBY} in
		*ruby18)
			emake -Cext/fastthread
			cp ext/fastthread/*$(get_modname) lib/ || die
			;;
		*)
			touch lib/fastthread.rb || die
			;;
	esac
}

each_ruby_test() {
	case ${RUBY} in
		*ruby18)
			${RUBY} -Ilib -S testrb test/test_*.rb || die
			;;
	esac
}
