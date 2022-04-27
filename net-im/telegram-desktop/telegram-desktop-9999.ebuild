# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs desktop xdg-utils xdg

inherit git-r3
# ^ TODO: conditional (only for 9999)? maybe port to tarballs before moving to gentoo repo.
inherit patches
# ^ TODO: drop before moving to gentoo repo, and port to manual selection

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org"

EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
EGIT_SUBMODULES=(
	'*'
	-Telegram/ThirdParty/{xxHash,Catch,lz4,libdbusmenu-qt,fcitx{5,}-qt{,5},hime,hunspell,nimf,qt5ct,range-v3,jemalloc}
)

if [[ "${PV}" == 9999 ]]; then
	KEYWORDS=""
	EGIT_BRANCH="dev"
else
	# TODO: tarballs
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
	# ~ppc64 # blocked by clang, expected, variant and so on. Although, proven to build (with gcc) and work by @gyakovlev
	# ~x86
	# ~arm ~arm64
	# ~mipsel
	# (blocked by dev-cpp/range, that have only "~amd64 ~ppc64" ATM, and I've no time to prove the build on others)
fi

LICENSE="GPL-3-with-openssl-exception"
SLOT="0"
IUSE="custom-api-id +dbus debug enchant hide-banned hide-sponsored-messages +hunspell libcxx lto pipewire +pulseaudio +spell +system-gsl +system-expected +system-libtgvoip system-rlottie +system-variant test +wayland +webkit +webrtc wide-baloons +X"

COMMON_DEPEND="
	!net-im/telegram
	!net-im/telegram-desktop-bin
	app-arch/lz4:=
	dev-libs/jemalloc:=[-lazy-lock]
	dev-libs/openssl:=
	dev-libs/xxhash:=
	>=dev-qt/qtcore-5.15:5
	>=dev-qt/qtgui-5.15:5[dbus?,jpeg,png,wayland?,X?]
	>=dev-qt/qtimageformats-5.15:5
	>=dev-qt/qtnetwork-5.15:5[ssl]
	>=dev-qt/qtsvg-5.15:5
	>=dev-qt/qtwidgets-5.15:5[png,X?]
	media-fonts/open-sans:*
	media-libs/fontconfig:=
	media-libs/rnnoise:=
	media-libs/libyuv:=
	media-libs/openal:=
	media-libs/opus:=
	media-video/ffmpeg:=[opus]
	dbus? (
		dev-cpp/glibmm:2
		dev-qt/qtdbus:5
		dev-libs/libdbusmenu-qt[qt5(+)]
	)
	libcxx? (
		sys-devel/clang:=
		sys-devel/clang-runtime:=[libcxx]
	)
	pipewire? ( media-video/pipewire )
	pulseaudio? ( media-sound/pulseaudio )
	system-libtgvoip? ( >media-libs/libtgvoip-2.4.4:=[libcxx=] )
	system-rlottie? ( >=media-libs/rlottie-0_pre20190818:=[libcxx(-)=,threads,-cache] )
	enchant? ( app-text/enchant:= )
	hunspell? ( >=app-text/hunspell-1.7:= )
	sys-libs/zlib:=[minizip]
	webrtc? (
		dev-cpp/abseil-cpp:=
		media-libs/libjpeg-turbo:=
		media-libs/libyuv:=
	)
	wayland? ( kde-frameworks/kwayland:= )
	webkit? ( net-libs/webkit-gtk:= )
	X? ( x11-libs/libxcb:= )
"

RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"
BDEPEND="
	${COMMON_DEPEND}
	system-variant? ( dev-cpp/variant:= )
	system-expected? ( >dev-cpp/tl-expected-1.0.0:= )
	system-gsl? ( >dev-cpp/ms-gsl-2.0.0:= )
	>=dev-cpp/range-v3-0.10.0:=
	>=dev-util/cmake-3.16
	|| (
		sys-devel/clang
		sys-devel/gcc
	)
	virtual/pkgconfig
	amd64? ( dev-lang/yasm )
"

REQUIRED_USE="
	spell? (
		^^ ( enchant hunspell )
	)
	webkit? ( dbus )
"



pkg_pretend() {
	if use wayland && use webkit; then
		ewarn "If you use Wayland as you main graphic system, keep in mind that embedded webview (webkit) that is used for payments doesn't work with it."
	fi
	if ! use webrtc; then
		eerror "Telegram Desktop's upstream made webrtc mandatory for build."
		eerror "We're working on patch to make it possible to disable it again, but it isn't ready atm."
		eerror "So, if build will fail - it is not a bug, you've been warned"
	fi
	if use custom-api-id; then
		if [[ -n "${TELEGRAM_CUSTOM_API_ID}" ]] && [[ -n "${TELEGRAM_CUSTOM_API_HASH}" ]]; then
			einfo "Your custom ApiId is ${TELEGRAM_CUSTOM_API_ID}"
			einfo "Your custom ApiHash is ${TELEGRAM_CUSTOM_API_HASH}"
		else
			eerror ""
			eerror "It seems you did not set one or both of TELEGRAM_CUSTOM_API_ID and TELEGRAM_CUSTOM_API_HASH variables,"
			eerror "which are required for custom-api-id USE-flag."
			eerror "You can set them either in:"
			eerror "- /etc/portage/make.conf (globally, so all applications you'll build will see that ID and HASH"
			eerror "- /etc/portage/env/${CATEGORY}/${PN} (privately for this package builds)"
			eerror ""
			die "You should correctly set both TELEGRAM_CUSTOM_API_ID and TELEGRAM_CUSTOM_API_HASH variables if you want custom-api-id USE-flag"
		fi
	fi

	if tc-is-gcc && ver_test "$(gcc-major-version).$(gcc-minor-version)" -lt "8.2" && [[ -z "${TG_FORCE_OLD_GCC}" ]]; then
		die "Minimal compatible gcc version is 8.2. Please, either upgrade or use clang. Or set TG_FORCE_OLD_GCC=1 to override this check."
	fi

	if get-flag -flto >/dev/null || use lto; then
		eerror ""
		eerror "Keep in mind, that building with LTO takes about ~20G RAM, and final binary size will be about 2.5G."
		if tc-is-clang; then
			eerror ""
			eerror "Qt5 is incompatible with LTO builds using clang at this moment."
			eerror "Ref: https://bugreports.qt.io/browse/QTBUG-61710"
			die "Please, read the error above."
		fi
	fi

	if [[ $(get-flag stdlib) == "libc++" ]]; then
		if ! tc-is-clang; then
			die "Building with libcxx (aka libc++) as stdlib requires using clang as compiler. Please set CC/CXX in portage.env"
		elif ! use libcxx; then
			die "Building with libcxx (aka libc++) as stdlib requires some dependencies to be also built with it. Please, set USE=libcxx on ${PN} to handle that."
		fi
	fi

	if use system-rlottie; then
		eerror "Currently, ${PN} is totally incompatible with Samsung's rlottie, and uses custom bundled fork."
		eerror "Build will definitelly fail. You've been warned!"
		eerror "Even if you have custom patches to make it build, there is another issue:"
		ewarn ""
		ewarn "Unfortunately, ${PN} uses custom modifications over rlottie (which aren't accepted by upstream, since they made it another way)."
		ewarn "This leads to following facts:"
		ewarn "  - Colors replacement maps are not working when you link against system rlottie package."
		ewarn "      That means, for example, that 'giant animated emojis' will ignore skin-tone colors and will always be yellow"
		ewarn "      Ref: https://github.com/Samsung/rlottie/pull/252"
		ewarn "  - Crashes on some stickerpacks"
		ewarn "      Probably related to: https://github.com/Samsung/rlottie/pull/262"
	fi
}

src_unpack() {
	use spell || EGIT_SUBMODULES+=(-Telegram/lib_spellcheck)
	use system-gsl && EGIT_SUBMODULES+=(-Telegram/ThirdParty/GSL)
	use system-expected && EGIT_SUBMODULES+=(-Telegram/ThirdParty/expected)
	use system-libtgvoip && EGIT_SUBMODULES+=(-Telegram/ThirdParty/libtgvoip)
	use system-variant && EGIT_SUBMODULES+=(-Telegram/ThirdParty/variant)
	use system-rlottie && EGIT_SUBMODULES+=(-Telegram/{lib_rlottie,ThirdParty/rlottie}) # Ref: https://bugs.gentoo.org/752417

	git-r3_src_unpack
}

src_prepare() {
	use system-rlottie || (
	# Ref: https://bugs.gentoo.org/752417
		sed -i \
			-e 's/DESKTOP_APP_USE_PACKAGED/0/' \
			cmake/external/rlottie/CMakeLists.txt || die
	)

	sed -i \
		-e '/-W.*/d' \
		-e '/PIC/a-Wno-error\n-Wno-all' \
		-e "$(usex debug '' 's@-g[a-zA-Z0-9]*@@')" \
		-e "$(usex lto '' 's@-flto@@')" \
		-e "s@-Ofast@@" \
		cmake/options_linux.cmake || die

#		echo > cmake/options_linux.cmake
#		^ Maybe just wipe it out instead of trying to fix?
#		^ There are not so mush useful compiler flags, actually.

	patches_src_prepare
#	cmake_src_prepare
#	^ to be used when will be ported to gentoo repo

	if use libcxx; then
		export CC="clang" CXX="clang++ -stdlib=libc++"
	fi
}

src_configure() {
	filter-flags '-DDEBUG' # produces bugs in bundled forks of 3party code
	append-cppflags '-DNDEBUG' # Telegram sets that in code (and I also forced that in ebuild to have the same behaviour), and segfaults on voice calls on mismatch (if tg was built with it, and deps are built without it, and vice versa)
	use lto && (
		append-flags '-flto'
		append-ldflags '-flto'
	)
	local mycxxflags=(
		${CXXFLAGS}
		-Wno-error=deprecated-declarations
		-Wno-deprecated-declarations
		-Wno-switch
		-DLIBDIR="$(get_libdir)"
		-DTDESKTOP_DISABLE_AUTOUPDATE
		$(usex webrtc "" "-DDESKTOP_APP_DISABLE_WEBRTC_INTEGRATION")
	)

	local mycmakeargs=(
		#-DCMAKE_DISABLE_FIND_PACKAGE_tl-expected=ON # header only lib, some git version. prevents warnings.
		-DCMAKE_CXX_FLAGS:="${mycxxflags[*]}"

		# Qt6 is not packaged in Gentoo at the moment.
		-DDESKTOP_APP_QT6=OFF

		# Upstream does not need crash reports from custom builds anyway
		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=ON

		-DDESKTOP_APP_DISABLE_SPELLCHECK=$(usex !spell)
		-DDESKTOP_APP_USE_ENCHANT=$(usex enchant)  # enables enchant and disables hunspell

		# Unbundling:
		-DDESKTOP_APP_USE_PACKAGED=ON # Main

		-DDESKTOP_APP_DISABLE_DBUS_INTEGRATION=$(usex !dbus)

		-DDESKTOP_APP_DISABLE_WAYLAND_INTEGRATION="$(usex !wayland)"
		# https://github.com/desktop-app/lib_ui/commit/d5a37c74b17b2c06b0d37f9a16129c70e0581c57#diff-1e7de1ae2d059d21e1dd75d5812d5a34b0222cef273b7c3a2af62eb747f9d20aR273-R281

		-DDESKTOP_APP_DISABLE_WEBKITGTK=$(usex !webkit)
		# Currently, only needs for "paymens" functionality, and also doesn't work on Wayland, and also with mutter WM.

		-DDESKTOP_APP_DISABLE_X11_INTEGRATION=$(usex !X)

		$(usex webrtc "" "-DDESKTOP_APP_DISABLE_WEBRTC_INTEGRATION=ON")

		$(usex lto "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON" '')

		-DTDESKTOP_API_TEST=$(usex test)

		# Snapcraft (snap, flatpack, whatever) API keys:
		# As of my discussion with John Preston, he specifically asked TG servers owners to never ban snap's keys:
		# TODO: (!!!!!!!) Ask Gentoo Council (or whatever) to get "official" Gentoo keys.
		-DTDESKTOP_API_ID=$(usex custom-api-id "${TELEGRAM_CUSTOM_API_ID}" "611335")
		-DTDESKTOP_API_HASH=$(usex custom-api-id "${TELEGRAM_CUSTOM_API_HASH}" "d524b414d21f4d37f08684c1df41ac9c")

#		-DDESKTOP_APP_LOTTIE_USE_CACHE=NO # in case of caching bugs. Maybe also useful with system-rlottie[cache]. TODO: test that idea.
	)
	cmake_src_configure
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
