# Building and installing glibc 2.27 on Ubuntu 18.04 LTS Bionic

The instructions here are mostly identical to building glibc 2.27 on Xenial.

The kernel support patches are still necessary, but we drop the GCC 5 support
patches because Bionic comes with GCC 7, which supports Static PIE executables.

## Add bionic sources repositories

/etc/apt/sources.list.d/bionic-src.list
```
deb-src http://archive.ubuntu.com/ubuntu bionic-updates main
deb-src http://archive.ubuntu.com/ubuntu bionic-security main
```

No need to get the bionic distribution as newer glibc sources are already in bionic-updates
or bionic-security.

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


## Download glibc bionic sources

```console
$ apt source --download-only glibc/bionic
```

## Extract and patch

```
$ dpkg-source -x glibc_2.27-3ubuntu1.6.dsc
$ patch -p0 < glibc-2.27-kernel-2.6.32.diff
$ patch -p0 < glibc-2.27-rlimit.diff
$ patch -p0 < glibc-2.27-missing-files.diff
$ patch -p0 < glibc-2.27-skip-tests.diff
$ patch -p0 < glibc-2.27-xenial-dependencies.diff
$ patch -p0 < glibc-2.27-no-udeb.diff
$ patch -p0 < glibc-2.27-no-nscd.diff
$ patch -p0 < glibc-2.27-no-glibc-source.diff
$ patch -p0 < glibc-2.27-no-glibc-doc.diff
$ patch -p0 < glibc-2.27-locales-c-only.diff
$ patch -p0 < glibc-2.27-no-dbg.diff
$ patch -p0 < glibc-2.27-no-pic.diff
$ patch -p0 < glibc-2.27-no-multiarch-support.diff
$ (cd glibc-2.27/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
$ (cd glibc-2.27/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)
$ make --silent -C glibc-2.27 -f debian/rules debian/control
$ sh glibc-2.27-patch-changelog-bionic.sh
```

The resulting binary packages will have the debian version prepended by "openvz6+ubuntu18.04+",
indicating that this build is specifically for Ubuntu 18.04 on OpenVZ6. This also ensures
that the interim glibc packages installed prior to upgrading to bionic will be upgraded
after the system upgrade.

As long as the upstream version does not change (we stay on the same LTS release),
our custom glibc packages will not be mistakenly overwritten by the official packages.

During upgrade to Ubuntu 18.04 LTS Bionic using do-release-upgrade, our custom repository
will be disabled. However, our custom versioning ensures that our glibc packages will not
be overwritten by packages from official Bionic repositories.

Reference:
- https://manpages.ubuntu.com/manpages/bionic/man7/deb-version.7.html


## Build the packages

```console
( cd glibc-2.27 && dpkg-buildpackage -rfakeroot -b -Jauto )
```

## Stage the packages

Make sure the directory `/var/lib/libc6-openvz6` is writable, then

```
$ mkdir -p /var/lib/libc6-openvz6/bionic-glibc-2.27
$ mv -i *.deb *.udeb /var/lib/libc6-openvz6/bionic-glibc-2.27
$ cd /var/lib/libc6-openvz6/bionic-glibc-2.27
$ apt-ftparchive packages . >Packages
$ apt-ftparchive release . >Release
```

## Upgrade to glibc 2.27

/etc/apt/sources.list.d/glibc.list
```
deb [trusted=yes] file:/var/lib/libc6-openvz6/bionic-glibc-2.27 ./
```

```
$ sudo apt update
$ sudo apt upgrade
```

## Notes

You can use the `build.sh` and `release.sh` convenience scripts to build the packages
and set up the local repo.

You can also remove the individual diff files and modify the default variables in
those scripts as needed.

