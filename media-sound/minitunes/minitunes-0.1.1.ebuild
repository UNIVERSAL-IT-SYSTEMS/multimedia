# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit qt4-r2

DESCRIPTION="Qt4 music player."
HOMEPAGE="http://flavio.tordini.org/minitunes"
SRC_URI="http://flavio.tordini.org/files/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	x11-libs/qt-gui:4[dbus]
	x11-libs/qt-sql:4[sqlite]
	|| ( x11-libs/qt-phonon:4 kde-base/phonon-kde )
	media-libs/taglib
"

S="${WORKDIR}/${PN}"

DOCS="CHANGES TODO"

src_configure() {
	eqmake4 ${PN}.pro PREFIX="/usr"
}
