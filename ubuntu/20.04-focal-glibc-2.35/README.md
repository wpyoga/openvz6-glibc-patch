# Building and installing glibc 2.35 on Ubuntu 20.04 LTS Focal

This is done before upgrading to Jammy.

We patch the package info in order to remove a conflict with fakeroot, and also avoid
the missing dependencies: rpcsvc-proto and libnsl-dev. These libraries are only
available after we upgrade to Jammy.

We also fix an issue with fchmodat(), which should set errno to EOPNOTSUPP instead of
changing the permissions of a symlink. This behavior broke `tar`, which relied on the
errno being set to ENOSYS, ENOTSUP or EOPNOTSUPP. We also fix an issue in tst-lchmod
regarding return value checking logic. This doesn't fix the tst-lchmod test though,
because there is another (unfixable?) issue with `unshare(CLONE_NEWNS)` on the
OpenVZ 6 kernel.

Debian started building memusagestat since glibc 2.33, which adds libgd-dev as a build
dependency. However, libgd-dev pulls in lots of other dependencies, so we skip it by
disabling the building of libc-devtools (which contains memusagestat). If you need it,
you can always install libc-devtools from the official repositories.

We disable building these:
- profiling libraries
- debug libraries
- nscd
- glibc-source & glibc-doc
- locales
- libc-dev-bin

You can enable them by not applying specific patches as shown below. We also
disable building multiarch libraries and udebs.

## Add jammy sources repositories

/etc/apt/sources.list.d/jammy-src.list
```
deb-src http://archive.ubuntu.com/ubuntu jammy-updates main
deb-src http://archive.ubuntu.com/ubuntu jammy-security main
```

No need to get the jammy distribution as newer glibc sources are already in jammy-updates
or jammy-security.

```console
$ sudo apt update
```

## Upgrade all packages

Upgrade all system packages. If some packages are held back, you may need to use
`apt full-upgrade` to do this.

## Install debian build tools and glibc build dependencies

```console
$ sudo apt install build-essential devscripts debhelper autoconf bison rdfind symlinks systemtap-sdt-dev libselinux1-dev libaudit-dev libcap-dev
```

If you want to build the multiarch packages, install `gcc-multilib` and `g++-multilib`
in addition to the above packages.

## Download glibc jammy sources

```console
$ apt source --download-only glibc/jammy
```

## Extract and patch

```
$ dpkg-source -x glibc_2.35-0ubuntu3.1.dsc
$ patch -p0 < glibc-2.35-kernel-2.6.32.diff
$ patch -p0 < glibc-2.35-rlimit.diff
$ patch -p0 < glibc-2.35-skip-tests.diff
$ patch -p0 < glibc-2.35-fchmodat.diff
$ patch -p0 < glibc-2.35-tst-lchmod.diff
$ patch -p0 < glibc-2.35-focal-dependencies.diff
$ patch -p0 < glibc-2.35-no-prof.diff
$ patch -p0 < glibc-2.35-no-devtools.diff
$ patch -p0 < glibc-2.35-no-nscd.diff
$ patch -p0 < glibc-2.35-no-glibc-source.diff
$ patch -p0 < glibc-2.35-no-glibc-doc.diff
$ patch -p0 < glibc-2.35-locales-c-only.diff
$ patch -p0 < glibc-2.35-no-dbg.diff
$ (cd glibc-2.35/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
$ (cd glibc-2.35/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)
$ make --silent -C glibc-2.35 -f debian/rules debian/control
$ sh glibc-2.35-patch-changelog-focal.sh
```

The resulting binary packages will have the debian version prepended by "openvz6+ubuntu20.04+",
indicating that this build is specifically for Ubuntu 20.04 on OpenVZ6.

As long as the upstream version does not change (we stay on the same LTS release),
our custom glibc packages will not be mistakenly overwritten by the official packages.

During upgrade to Ubuntu 22.04 LTS Jammy using do-release-upgrade, our custom repository
will be disabled. However, our custom versioning ensures that our glibc packages will not
be overwritten by packages from official Jammy repositories.

Reference:
- https://manpages.ubuntu.com/manpages/focal/man7/deb-version.7.html


## Build the packages

```console
$ export DEB_BUILD_OPTIONS="noautodbgsym"
$ export DEB_BUILD_PROFILES="nobiarch noudeb"
$ ( cd glibc-2.35 && dpkg-buildpackage -rfakeroot -b -Jauto )
```

## Stage the packages

Make sure the directory `/var/lib/libc6-openvz6` is writable, then

```
$ mkdir -p /var/lib/libc6-openvz6/focal-glibc-2.35
$ mv -i *.deb /var/lib/libc6-openvz6/focal-glibc-2.35
$ cd /var/lib/libc6-openvz6/focal-glibc-2.35
$ apt-ftparchive packages . >Packages
$ apt-ftparchive release . >Release
```

## Upgrade to glibc 2.35

/etc/apt/sources.list.d/glibc.list
```
deb [trusted=yes] file:/var/lib/libc6-openvz6/focal-glibc-2.35 ./
```

```
$ sudo apt update
$ sudo apt full-upgrade
```

Use `full-upgrade` instead of `upgrade` because libc6 has a new dependency `libtirpc-dev`.

## Notes

You can use the `build.sh` and `release.sh` convenience scripts to build the packages
and set up the local repo.

You can also remove the individual diff files and modify the default variables in
those scripts as needed.

