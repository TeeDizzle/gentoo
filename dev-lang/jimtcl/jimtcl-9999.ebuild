# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="http://repo.or.cz/r/jimtcl.git"
	inherit git-r3
else
	SRC_URI="https://github.com/msteveb/jimtcl/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~m68k ~mips ~s390 ~sh ~x86"
fi

DESCRIPTION="Small footprint implementation of Tcl programming language"
HOMEPAGE="http://jim.tcl.tk/"

LICENSE="LGPL-2"
SLOT="0"
IUSE="doc static-libs"

RDEPEND=""
DEPEND="doc? ( app-text/asciidoc )
	app-arch/unzip"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git-2_src_unpack
	else
		default
	fi
}

src_configure() {
	CCACHE=None econf --with-jim-shared
	if use static-libs ; then
		# The build does not support doing both simultaneously.
		mkdir static-libs || die
		cd static-libs || die
		CCACHE=None ECONF_SOURCE=${S} econf
	fi
}

src_compile() {
	# Must build static-libs first.
	use static-libs && emake -C static-libs libjim.a
	emake all
	use doc && emake docs
}

src_install() {
	dobin jimsh
	use static-libs && dolib.a static-libs/libjim.a
	ln -sf libjim.so.* libjim.so || die
	dolib.so libjim.so*
	insinto /usr/include
	doins jim.h jimautoconf.h jim-subcmd.h jim-signal.h \
		jim-win32compat.h jim-eventloop.h jim-config.h
	dodoc AUTHORS README TODO
	dodoc Tcl.html
}
