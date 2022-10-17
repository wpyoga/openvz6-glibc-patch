# Building and installing glibc 2.35 on Ubuntu 20.04 LTS Focal

This is done before upgrading to Focal.

## Upgrade all packages

First, upgrade all system packages.

Some questions will be asked, just keep to the default answers and it's usually fine.

## Add focal-backports and jammy sources repositories

/etc/apt/sources.list.d/backports.list
```
deb http://archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse
```

/etc/apt/sources.list.d/jammy-src.list
```
deb-src http://archive.ubuntu.com/ubuntu jammy main
deb-src http://archive.ubuntu.com/ubuntu jammy-updates main
deb-src http://archive.ubuntu.com/ubuntu jammy-security main
```

```console
$ sudo apt update
```

## Install debian build tools and glibc build dependencies

```console
$ sudo apt install build-essential devscripts debhelper bison rdfind symlinks systemtap-sdt-dev libselinux1-dev gcc-multilib g++-multilib libgd-dev libaudit-dev libcap-dev
```

## Download glibc jammy sources

```console
$ apt source --download-only glibc/jammy
```

## Extract and patch

```
$ dpkg-source -x glibc_2.35-0ubuntu9.2.dsc
$ patch -p0 < glibc-2.35-kernel-2.6.32.diff
$ patch -p0 < glibc-2.35-rlimit.diff
$ patch -p0 < glibc-2.35-skip-tests.diff
$ (cd glibc-2.35/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
$ (cd glibc-2.35/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)
$ sh glibc-2.35-patch-changelog-jammy.sh
```

The resulting binary packages will have the debian version prepended by "openvz6+ubuntu20.04+",
indicating that this build is specifically for Ubuntu 20.04 on OpenVZ6. This also ensures
that the interim glibc packages installed prior to upgrading to jammy will be upgraded
after the system upgrade.

As long as the upstream version does not change (we stay on the same LTS release),
our custom glibc packages will not be mistakenly overwritten by the official packages.

Reference:
- https://manpages.ubuntu.com/manpages/jammy/man7/deb-version.7.html


## Build the packages

```console
( cd glibc-2.35 && dpkg-buildpackage -rfakeroot -b -d -Jauto )
```

## Stage the packages

```
$ sudo mkdir -p /var/lib/libc6-openvz6/jammy-glibc-2.35
$ sudo chown myuser: /var/lib/libc6-openvz6/jammy-glibc-2.35
$ mv -i *.deb *.udeb *.ddeb /var/lib/libc6-openvz6/jammy-glibc-2.35
$ cd /var/lib/libc6-openvz6/jammy-glibc-2.35
$ apt-ftparchive packages . >Packages
$ apt-ftparchive release . >Release
```

## Upgrade to glibc 2.31

/etc/apt/sources.list.d/glibc.list
```
deb [trusted=yes] file:/var/lib/libc6-openvz6/focal-glibc-2.31 ./
```

```
$ sudo apt update
$ sudo apt upgrade
```

