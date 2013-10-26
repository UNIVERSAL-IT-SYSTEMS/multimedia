# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="git://github.com/mpv-player/mpv.git"
EGIT_BRANCH="waf"

inherit toolchain-funcs flag-o-matic multilib base waf-utils pax-utils
[[ ${PV} == *9999* ]] && inherit git-2

DESCRIPTION="Video player based on MPlayer/mplayer2"
HOMEPAGE="http://mpv.io/"
[[ ${PV} == *9999* ]] || \
SRC_URI="https://github.com/mpv-player/mpv/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
[[ ${PV} == *9999* ]] || \
KEYWORDS="~alpha ~amd64 ~arm ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux"
IUSE="+alsa bluray bs2b +cdio doc-pdf dvb +dvd +enca encode +iconv jack joystick
jpeg ladspa lcms +libass libcaca libguess lirc lua luajit mng +mp3 -openal +opengl oss
portaudio +postproc pulseaudio pvr +quvi radio samba +shm +threads v4l vaapi
vcd vdpau vf-dlopen wayland +X xinerama +xscreensaver +xv"

REQUIRED_USE="
	enca? ( iconv )
	lcms? ( opengl )
	libguess? ( iconv )
	luajit? ( lua )
	opengl? ( || ( wayland X ) )
	portaudio? ( threads )
	pvr? ( v4l )
	radio? ( v4l || ( alsa oss ) )
	v4l? ( threads )
	vaapi? ( X )
	vdpau? ( X )
	wayland? ( opengl )
	xinerama? ( X )
	xscreensaver? ( X )
	xv? ( X )
"

RDEPEND+="
	|| (
		>=media-video/libav-9:=[encode?,threads?,vaapi?,vdpau?]
		>=media-video/ffmpeg-1.2:0=[encode?,threads?,vaapi?,vdpau?]
	)
	sys-libs/ncurses
	sys-libs/zlib
	X? (
		x11-libs/libXext
		x11-libs/libXxf86vm
		opengl? ( virtual/opengl )
		lcms? ( media-libs/lcms:2 )
		vaapi? ( x11-libs/libva[X(+)] )
		vdpau? ( x11-libs/libvdpau )
		xinerama? ( x11-libs/libXinerama )
		xscreensaver? ( x11-libs/libXScrnSaver )
		xv? ( x11-libs/libXv )
	)
	alsa? ( media-libs/alsa-lib )
	bluray? ( media-libs/libbluray )
	bs2b? ( media-libs/libbs2b )
	cdio? (
		|| (
			dev-libs/libcdio-paranoia
			<dev-libs/libcdio-0.90[-minimal]
		)
	)
	dvb? ( virtual/linuxtv-dvb-headers )
	dvd? ( >=media-libs/libdvdread-4.1.3 )
	enca? ( app-i18n/enca )
	iconv? ( virtual/libiconv )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg? ( virtual/jpeg )
	ladspa? ( media-libs/ladspa-sdk )
	libass? (
		>=media-libs/libass-0.9.10[enca?,fontconfig]
		virtual/ttf-fonts
	)
	libcaca? ( media-libs/libcaca )
	libguess? ( >=app-i18n/libguess-1.0 )
	lirc? ( app-misc/lirc )
	lua? (
		!luajit? ( >=dev-lang/lua-5.1 )
		luajit? ( dev-lang/luajit:2 )
	)
	mng? ( media-libs/libmng )
	mp3? ( media-sound/mpg123 )
	openal? ( >=media-libs/openal-1.13 )
	portaudio? ( >=media-libs/portaudio-19_pre20111121 )
	postproc? (
		|| (
			media-libs/libpostproc
			>=media-video/ffmpeg-1.2:0[encode?,threads?,vaapi?,vdpau?]
		)
	)
	pulseaudio? ( media-sound/pulseaudio )
	quvi? (
		>=media-libs/libquvi-0.4.1:=
		|| (
			>=media-video/libav-9[network]
			>=media-video/ffmpeg-1.2:0[network]
		)
	)
	samba? ( net-fs/samba )
	wayland? (
		>=dev-libs/wayland-1.0.0
		media-libs/mesa[egl,wayland]
		>=x11-libs/libxkbcommon-0.3.0
	)
"
ASM_DEP="dev-lang/yasm"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=dev-lang/perl-5.8
	dev-python/docutils
	doc-pdf? (
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexrecommended
		dev-texlive/texlive-latexextra
		dev-tex/xcolor
	)
	X? (
		x11-proto/videoproto
		x11-proto/xf86vidmodeproto
		xinerama? ( x11-proto/xineramaproto )
		xscreensaver? ( x11-proto/scrnsaverproto )
	)
	amd64? ( ${ASM_DEP} )
	x86? ( ${ASM_DEP} )
	x86-fbsd? ( ${ASM_DEP} )
"

pkg_setup() {
	if [[ ${PV} == *9999* ]]; then
		elog
		elog "This is a live ebuild which installs the latest from upstream's"
		elog "git repository, and is unsupported by Gentoo."
		elog "Everything but bugs in the ebuild itself will be ignored."
		elog
	fi

	if use !libass; then
		ewarn
		ewarn "You've disabled the libass flag. No OSD or subtitles will be displayed."
	fi

	if use openal; then
		ewarn
		ewarn "You've enabled the openal flag. OpenAL is disabled by default,"
		ewarn "because it supposedly inteferes with some other configure tests"
		ewarn "and makes them fail silently."
	fi

	einfo "For additional format support you need to enable the support on your"
	einfo "libavcodec/libavformat provider:"
	einfo "    media-video/libav or media-video/ffmpeg"
}

src_prepare() {
	base_src_prepare
}

src_configure() {
# TODO upstream
#		$(use_enable doc-pdf pdf) \

	if use x86 && gcc-specs-pie; then
		filter-flags -fPIC -fPIE
		append-ldflags -nopie
	fi

	# keep build reproducible
	# SDL output is fallback for platforms where nothing better is available
	# media-sound/rsound is in pro-audio overlay only
	NO_WAF_LIBDIR=1 \
	waf-utils_src_configure \
		--disable-build-date \
		--disable-sdl \
		--disable-sdl2 \
		--disable-rsound \
		$(use_enable encode encoding) \
		$(use_enable joystick) \
		$(use_enable bluray libbluray) \
		$(use_enable vcd) \
		$(use_enable quvi libquvi4) \
		--disable-libquvi9 \
		$(use_enable samba libsmbclient) \
		$(use_enable lirc) \
		$(use_enable lirc lircc) \
		$(use_enable lua) \
		$(usex luajit '--lua=luajit' '') \
		$(use_enable cdio cdda) \
		$(use_enable dvd dvdread) \
		$(use_enable enca) \
		$(use_enable iconv) \
		$(use_enable libass) \
		$(use_enable libguess) \
		$(use_enable dvb) \
		$(use_enable pvr) \
		$(use_enable v4l tv) \
		$(use_enable v4l tv-v4l2) \
		$(use_enable radio) \
		$(use_enable radio radio-capture) \
		$(use_enable radio radio-v4l2) \
		$(use_enable mp3 mpg123) \
		$(use_enable jpeg) \
		$(use_enable mng) \
		$(use_enable libcaca caca) \
		$(use_enable postproc libpostproc) \
		$(use_enable alsa) \
		$(use_enable jack) \
		$(use_enable ladspa) \
		$(use_enable portaudio) \
		$(use_enable bs2b libbs2b) \
		$(use_enable openal) \
		$(use_enable oss oss_audio) \
		$(use_enable pulseaudio pulse) \
		$(use_enable threads pthreads) \
		$(use_enable shm) \
		$(use_enable X x11) \
		$(use_enable vaapi) \
		$(use_enable vdpau) \
		$(use_enable wayland) \
		$(use_enable xinerama) \
		$(use_enable xv) \
		$(use_enable opengl gl) \
		$(use_enable lcms lcms2) \
		$(use_enable xscreensaver xss) \
		--confdir="${EPREFIX}"/etc/${PN} \
		--mandir="${EPREFIX}"/usr/share/man
}

src_compile() {
	waf-utils_src_compile

	if use vf-dlopen; then
		tc-export CC
		emake -C TOOLS/vf_dlopen
	fi
}

src_install() {
	dobin build/mpv

	if use luajit; then
		pax-mark -m "${ED}"usr/bin/mpv
	fi

	if use vf-dlopen; then
		exeinto /usr/$(get_libdir)/${PN}
		doexe TOOLS/vf_dlopen/*.so
	fi

	domenu etc/mpv.desktop
	dodoc Copyright README.md etc/{encoding-example-profiles.conf,example.conf,input.conf}
}