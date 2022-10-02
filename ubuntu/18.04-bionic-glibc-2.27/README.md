# Building and installing glibc 2.27 on Ubuntu 18.04 LTS Bionic

The instructions here are mostly identical to building glibc 2.27 on Xenial.
The kernel support patches are still necessary, but we drop the GCC 5 support
patches. Bionic comes with GCC 7, which supports Static PIE executables, which
is a requirement for glibc 2.27.

## Upgrade all packages

First, upgrade all system packages.

Some questions will be asked, just keep to the default answers and it's usually fine.

## Add bionic-backports and bionic sources repositories

/etc/apt/sources.list.d/backports.list
```
deb http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse
```

/etc/apt/sources.list.d/bionic-src.list
```
deb-src http://archive.ubuntu.com/ubuntu bionic main
deb-src http://archive.ubuntu.com/ubuntu bionic-updates main
deb-src http://archive.ubuntu.com/ubuntu bionic-security main
```

```console
$ sudo apt update
```

## Install debian build tools and glibc build dependencies

```console
$ sudo apt install build-essential devscripts debhelper bison rdfind symlinks systemtap-sdt-dev libselinux1-dev gcc-multilib g++-multilib libgd-dev libaudit-dev libcap-dev
```

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
$ (cd glibc-2.27/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
$ (cd glibc-2.27/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)
$ sh glibc-2.27-patch-changelog-bionic.sh
```

The resulting binary packages will have the debian version prepended by "openvz6+ubuntu18.04+",
indicating that this build is specifically for Ubuntu 18.04 on OpenVZ6. This also ensures
that the interim glibc packages installed prior to upgrading to bionic will be upgraded
after the system upgrade.

As long as the upstream version does not change (we stay on the same LTS release),
our custom glibc packages will not be mistakenly overwritten by the official packages.

Reference:
- https://manpages.ubuntu.com/manpages/bionic/man7/deb-version.7.html


## Build the packages

```console
( cd glibc-2.27 && dpkg-buildpackage -rfakeroot -b -d -Jauto )
```

## Stage the packages

```
$ sudo mkdir -p /var/lib/libc6-openvz6/bionic-glibc-2.27
$ sudo chown myuser: /var/lib/libc6-openvz6/bionic-glibc-2.27
$ mv -i *.deb *.udeb /var/lib/libc6-openvz6/bionic-glibc-2.27
$ cd /var/lib/libc6-openvz6/bionic-glibc-2.27
$ apt-ftparchive packages . >Packages
$ apt-ftparchive release . >Release
```

## Upgrade to glibc 2.27

/etc/apt/sources.list.d/bionic-glibc-2.27.list
```
deb [trusted=yes] file:/var/lib/libc6-openvz6 bionic-glibc-2.27/
```

```
$ sudo apt update
$ sudo apt upgrade
```

