# Building and installing glibc 2.31 on Ubuntu 18.04 LTS Bionic

This is done before upgrading to Focal.

## Upgrade all packages

First, upgrade all system packages.

Some questions will be asked, just keep to the default answers and it's usually fine.

## Add focal-backports and focal sources repositories

/etc/apt/sources.list.d/backports.list
```
deb http://archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse
```

/etc/apt/sources.list.d/focal-src.list
```
deb-src http://archive.ubuntu.com/ubuntu focal main
deb-src http://archive.ubuntu.com/ubuntu focal-updates main
deb-src http://archive.ubuntu.com/ubuntu focal-security main
```

```console
$ sudo apt update
```

## Install debian build tools and glibc build dependencies

```console
$ sudo apt install build-essential devscripts debhelper bison rdfind symlinks systemtap-sdt-dev libselinux1-dev gcc-multilib g++-multilib libgd-dev libaudit-dev libcap-dev
```

## Download glibc focal sources

```console
$ apt source --download-only glibc/focal
```

## Extract and patch

```
$ dpkg-source -x glibc_2.31-0ubuntu9.2.dsc
$ patch -p0 < glibc-2.31-kernel-2.6.32.diff
$ patch -p0 < glibc-2.31-rlimit.diff
$ patch -p0 < glibc-2.31-missing-files.diff
$ patch -p0 < glibc-2.31-gcc-7.diff
$ patch -p0 < glibc-2.31-skip-tests.diff
$ (cd glibc-2.31/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
$ (cd glibc-2.31/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)
$ sh glibc-2.31-patch-changelog-bionic.sh
```

The resulting binary packages will have the debian version prepended by "openvz6+ubuntu18.04+",
indicating that this build is specifically for Ubuntu 18.04 on OpenVZ6.

As long as the upstream version does not change (we stay on the same LTS release),
our custom glibc packages will not be mistakenly overwritten by the official packages.

During upgrade to Ubuntu 20.04 LTS Focal using do-release-upgrade, our custom repository
will be disabled. However, our custom versioning ensures that our glibc packages will not
be overwritten by packages from focal.

Reference:
- https://manpages.ubuntu.com/manpages/bionic/man7/deb-version.7.html


## Build the packages

```console
( cd glibc-2.31 && dpkg-buildpackage -rfakeroot -b -d -Jauto )
```

## Stage the packages

```
$ sudo mkdir -p /var/lib/libc6-openvz6/bionic-glibc-2.31
$ sudo chown myuser: /var/lib/libc6-openvz6/bionic-glibc-2.31
$ mv -i *.deb *.udeb /var/lib/libc6-openvz6/bionic-glibc-2.31
$ cd /var/lib/libc6-openvz6/bionic-glibc-2.31
$ apt-ftparchive packages . >Packages
$ apt-ftparchive release . >Release
```

## Upgrade to glibc 2.31

/etc/apt/sources.list.d/bionic-glibc-2.31.list
```
deb [trusted=yes] file:/var/lib/libc6-openvz6/bionic-glibc-2.31 ./
```

```
$ sudo apt update
$ sudo apt upgrade
```
