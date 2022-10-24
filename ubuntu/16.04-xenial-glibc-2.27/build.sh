#!/bin/sh

dpkg-source -x glibc_2.27-3ubuntu1.6.dsc

patch -p0 < glibc-2.27-kernel-2.6.32.diff
patch -p0 < glibc-2.27-rlimit.diff
patch -p0 < glibc-2.27-missing-files.diff
patch -p0 < glibc-2.27-gcc-5.diff
patch -p0 < glibc-2.27-skip-tests.diff
patch -p0 < glibc-2.27-xenial-dependencies.diff

patch -p0 < glibc-2.27-no-udeb.diff
patch -p0 < glibc-2.27-no-nscd.diff
patch -p0 < glibc-2.27-no-glibc-source.diff
patch -p0 < glibc-2.27-no-glibc-doc.diff
patch -p0 < glibc-2.27-locales-c-only.diff
patch -p0 < glibc-2.27-no-dbg.diff
patch -p0 < glibc-2.27-no-pic.diff
patch -p0 < glibc-2.27-no-multiarch-support.diff

(cd glibc-2.27/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
(cd glibc-2.27/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)

make --silent -C glibc-2.27 -f debian/rules debian/control

sh glibc-2.27-patch-changelog-xenial.sh

export DEB_BUILD_OPTIONS="nocheck"
export DEB_BUILD_PROFILES="nobiarch"
#export PARALLELMFLAGS="-j8 -O"
export DPKG_JFLAGS="-Jauto"

screen -dmL sh -c 'cd glibc-2.27 && dpkg-buildpackage -rfakeroot -b $DPKG_JFLAGS'

