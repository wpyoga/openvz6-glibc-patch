#!/bin/sh

sudo chmod 666 /dev/ptmx

dpkg-source -x glibc_2.31-0ubuntu9.9.dsc

patch -p0 < glibc-2.31-kernel-2.6.32.diff
patch -p0 < glibc-2.31-rlimit.diff
patch -p0 < glibc-2.31-gcc-7.diff
patch -p0 < glibc-2.31-skip-tests.diff
patch -p0 < glibc-2.31-bionic-dependencies.diff

patch -p0 < glibc-2.31-no-prof.diff
patch -p0 < glibc-2.31-no-nscd.diff
patch -p0 < glibc-2.31-no-glibc-source.diff
patch -p0 < glibc-2.31-no-glibc-doc.diff
patch -p0 < glibc-2.31-locales-c-only.diff
patch -p0 < glibc-2.31-no-dbg.diff
patch -p0 < glibc-2.31-no-pic.diff

(cd glibc-2.31/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
(cd glibc-2.31/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)

make --silent -C glibc-2.31 -f debian/rules debian/control

sh glibc-2.31-patch-changelog-bionic.sh

export DEB_BUILD_OPTIONS="nocheck noautodbgsym"
export DEB_BUILD_PROFILES="nobiarch noudeb nocheck"
#export PARALLELMFLAGS="-j8 -O"
export DPKG_JFLAGS="-Jauto"

screen -dmL sh -c 'cd glibc-2.31 && dpkg-buildpackage -rfakeroot -b $DPKG_JFLAGS'

