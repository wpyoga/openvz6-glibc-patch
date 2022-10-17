# Building and installing glibc 2.35 on Ubuntu 20.04 LTS Focal

This is done before upgrading to Jammy.

We patch the package info in order to remove a conflict with fakeroot, and also avoid
the missing dependencies: rpcsvc-proto, libtirpc-dev, and libnsl-dev. These libraries
are only available after we upgrade to Jammy.

## Add focal-backports and jammy sources repositories

/etc/apt/sources.list.d/backports.list
```
deb http://archive.ubuntu.com/ubuntu focal-backports main universe
```

/etc/apt/sources.list.d/jammy-src.list
```
deb-src http://archive.ubuntu.com/ubuntu jammy-updates main
deb-src http://archive.ubuntu.com/ubuntu jammy-security main
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
$ sudo apt install build-essential devscripts debhelper bison rdfind symlinks systemtap-sdt-dev libselinux1-dev gcc-multilib g++-multilib libaudit-dev libcap-dev
```

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
$ patch -p0 < glibc-2.35-focal-dependencies.diff
$ (cd glibc-2.35/sysdeps/unix/sysv/linux; autoconf -I ../../../.. -o configure configure.ac)
$ (cd glibc-2.35/sysdeps/unix/sysv/linux/x86_64/x32; autoconf -I ../../../../../.. -o configure configure.ac)
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
( cd glibc-2.35 && dpkg-buildpackage -rfakeroot -b -d -Jauto )
```

## Stage the packages

```
$ sudo mkdir -p /var/lib/libc6-openvz6/focal-glibc-2.35
$ sudo chown myuser: /var/lib/libc6-openvz6/focal-glibc-2.35
$ mv -i *.deb *.ddeb /var/lib/libc6-openvz6/focal-glibc-2.35
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

Use `full-upgrade` instead of `upgrade` because of some conflicting dependencies.

