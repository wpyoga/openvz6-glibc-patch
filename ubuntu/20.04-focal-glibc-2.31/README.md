# Building and installing glibc 2.31 on Ubuntu 20.04 LTS Focal

The instructions here are mostly identical to building glibc 2.31 on Bionic.

The kernel support patches are still necessary, but we drop the GCC 7 support
patches because Bionic comes with GCC 7, which supports CET and recognizes
previously-declared static const variables as constants.

## Add focal-backports and focal sources repositories

/etc/apt/sources.list.d/backports.list
```
deb http://archive.ubuntu.com/ubuntu focal-backports main universe
```

/etc/apt/sources.list.d/focal-src.list
```
deb-src http://archive.ubuntu.com/ubuntu focal-updates main
deb-src http://archive.ubuntu.com/ubuntu focal-security main
```

No need to get the bionic distribution as newer glibc sources are already in focal-updates
or focal-security.

```console
$ sudo apt update
```

## Upgrade all packages

Upgrade all system packages. If some packages are held back, you may need to use
`apt full-upgrade` to do this.

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
$ patch -p0 < glibc-2.31-skip-tests.diff
$ (cd glibc-2.31/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
$ (cd glibc-2.31/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)
$ sh glibc-2.31-patch-changelog-focal.sh
```

The resulting binary packages will have the debian version prepended by "openvz6+ubuntu20.04+",
indicating that this build is specifically for Ubuntu 20.04 on OpenVZ6. This also ensures
that the interim glibc packages installed prior to upgrading to focal will be upgraded
after the system upgrade.

As long as the upstream version does not change (we stay on the same LTS release),
our custom glibc packages will not be mistakenly overwritten by the official packages.

Reference:
- https://manpages.ubuntu.com/manpages/focal/man7/deb-version.7.html


## Build the packages

```console
( cd glibc-2.31 && dpkg-buildpackage -rfakeroot -b -d -Jauto )
```

## Stage the packages

```
$ sudo mkdir -p /var/lib/libc6-openvz6/focal-glibc-2.31
$ sudo chown myuser: /var/lib/libc6-openvz6/focal-glibc-2.31
$ mv -i *.deb *.udeb *.ddeb /var/lib/libc6-openvz6/focal-glibc-2.31
$ cd /var/lib/libc6-openvz6/focal-glibc-2.31
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

