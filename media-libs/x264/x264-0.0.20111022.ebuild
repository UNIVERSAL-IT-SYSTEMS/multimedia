# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/x264/x264-9999.ebuild,v 1.1 2011/05/28 06:30:08 radhermit Exp $

EAPI=4

if [ "${PV#9999}" != "${PV}" ] ; then
	V_ECLASS="git-2"
else
	V_ECLASS="versionator"
fi

inherit multilib toolchain-funcs ${V_ECLASS}

if [ "${PV#9999}" = "${PV}" ] ; then
	MY_P="x264-snapshot-$(get_version_component_range 3)-2245-stable"
fi
DESCRIPTION="A free library for encoding X264/AVC streams"
HOMEPAGE="http://www.videolan.org/developers/x264.html"
if [ "${PV#9999}" != "${PV}" ] ; then
	EGIT_REPO_URI="git://git.videolan.org/x264.git"
	SRC_URI=""
else
	SRC_URI="http://download.videolan.org/pub/videolan/x264/snapshots/${MY_P}.tar.bz2"
fi

LICENSE="GPL-2"
SLOT="0"
if [ "${PV#9999}" != "${PV}" ] ; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
fi
IUSE="10bit debug +interlaced pic static-libs +threads"

RDEPEND=""
ASM_DEP=">=dev-lang/yasm-0.6.2"
DEPEND="
	amd64? ( ${ASM_DEP} )
	x86? ( ${ASM_DEP} )
	x86-fbsd? ( ${ASM_DEP} )
"
if [ "${PV#9999}" = "${PV}" ] ; then
	S=${WORKDIR}/${MY_P}
fi
DOCS="AUTHORS doc/*.txt"

src_configure() {
	tc-export CC

	local myconf=""
	use 10bit && myconf+=" --bit-depth=10"
	use debug && myconf+=" --enable-debug"
	use interlaced || myconf+=" --disable-interlaced"
	use static-libs && myconf+=" --enable-static"
	use threads || myconf+=" --disable-thread"

	if use x86 && use pic; then
		myconf+=" --disable-asm"
	fi

	./configure \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--disable-cli \
		--disable-avs \
		--disable-lavf \
		--disable-swscale \
		--disable-ffms \
		--disable-gpac \
		--enable-pic \
		--enable-shared \
		--host="${CHOST}" \
		${myconf} || die
}
