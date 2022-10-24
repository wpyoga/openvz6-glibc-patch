#!/bin/sh

sudo chmod 666 /dev/ptmx

dpkg-source -x glibc_2.35-0ubuntu3.1.dsc

patch -p0 < glibc-2.35-kernel-2.6.32.diff
patch -p0 < glibc-2.35-rlimit.diff
patch -p0 < glibc-2.35-aclocal.diff
patch -p0 < glibc-2.35-skip-tests.diff
patch -p0 < glibc-2.35-fchmodat.diff
patch -p0 < glibc-2.35-tst-lchmod.diff
patch -p0 < glibc-2.35-jammy-dependencies.diff

patch -p0 < glibc-2.35-no-prof.diff
patch -p0 < glibc-2.35-no-devtools.diff
patch -p0 < glibc-2.35-no-nscd.diff
patch -p0 < glibc-2.35-no-glibc-source.diff
patch -p0 < glibc-2.35-no-glibc-doc.diff
patch -p0 < glibc-2.35-locales-c-only.diff
patch -p0 < glibc-2.35-no-dbg.diff

(cd glibc-2.35/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
(cd glibc-2.35/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)

make --silent -C glibc-2.35 -f debian/rules debian/control

sh glibc-2.35-patch-changelog-jammy.sh

export DEB_BUILD_OPTIONS="nocheck noautodbgsym"
#export DEB_BUILD_PROFILES="nobiarch noudeb"
#export PARALLELMFLAGS="-j8 -O"
export DPKG_JFLAGS="-Jauto"

screen -dmL sh -c 'cd glibc-2.35 && dpkg-buildpackage -rfakeroot -b $DPKG_JFLAGS --build-profiles="nobiarch,noudeb"'

