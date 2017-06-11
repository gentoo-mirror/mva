# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_RUBY="ruby21 ruby22 ruby23"

RUBY_FAKEGEM_TASK_DOC=""

RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.rdoc"

RUBY_FAKEGEM_GEMSPEC="activesupport.gemspec"

RUBY_FAKEGEM_BINWRAP=""

inherit ruby-fakegem versionator

DESCRIPTION="Utility Classes and Extension to the Standard Library"
HOMEPAGE="https://github.com/rails/rails"
SRC_URI="https://github.com/rails/rails/archive/v${PV}.tar.gz -> rails-${PV}.tgz"

LICENSE="MIT"
SLOT="$(get_version_component_range 1-2)"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc64 ~x86 ~amd64-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RUBY_S="rails-${PV}/${PN}"

ruby_add_rdepend "
	>=dev-ruby/i18n-0.6.9:0.6
	>=dev-ruby/multi_json-1.3:0
	>=dev-ruby/tzinfo-0.3.37:0
	>=dev-ruby/minitest-4.2:0
	>=dev-ruby/thread_safe-0.1:0"

PATCHES=( "${FILESDIR}/4-1-xml_depth.patch" )

all_ruby_prepare() {
	# Set the secure permissions that tests expect.
	chmod 0755 "${HOME}" || die "Failed to fix permissions on home"

	# Set test environment to our hand.
#	rm "${S}/../Gemfile" || die "Unable to remove Gemfile"
	sed -i -e '/load_paths/d' test/abstract_unit.rb || die "Unable to remove load paths"

	# Make sure a compatible version of minitest is used everywhere.
	sed -i -e "s/gem 'minitest'/gem 'minitest', '~> 4.2'/" lib/active_support/test_case.rb || die
	sed -i -e "1igem 'minitest', '~> 4.2'" test/abstract_unit.rb || die

	# Avoid test that seems to be broken by lack of DST.
	sed -i -e '324 s:^:#:' test/core_ext/string_ext_test.rb || die
}
