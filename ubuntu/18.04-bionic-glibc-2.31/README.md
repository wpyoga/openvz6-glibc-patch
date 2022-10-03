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
$ dpkg-source -x glibc_2.31-0ubuntu9.9.dsc
$ patch -p0 < glibc-2.31-kernel-2.6.32.diff
$ patch -p0 < glibc-2.31-rlimit.diff
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
$ mv -i *.deb *.udeb *.ddeb /var/lib/libc6-openvz6/bionic-glibc-2.31
$ cd /var/lib/libc6-openvz6/bionic-glibc-2.31
$ apt-ftparchive packages . >Packages
$ apt-ftparchive release . >Release
```

## Upgrade to glibc 2.31

This time the upgrade cannot be done in a simple manner, without upgrading the system.

1. Update all other packages first
1. Prepare for upgrade to glibc 2.31
1. Modify do-release-upgrade to remove check for upgradable packages
1. Run do-release-upgrade

TODO: patch out features and dependencies in order to be able to upgrade glibc without
upgrading the system at this stage. We will rebuild glibc will all the features after
upgrading anyway.
- One possible solution is to patch the dependency to libgcc-s1 and change it to libgcc1
- Need to look at the other broken dependencies as well
- We won't need to do this in the rebuild after upgrade.

### Preparing for upgrade to glibc 2.31

/etc/apt/sources.list.d/bionic-glibc-2.31.list
```
deb [trusted=yes] file:/var/lib/libc6-openvz6/bionic-glibc-2.31 ./
```

```
$ sudo apt update
```

### Modify do-release-upgrade

Change the line

```
for pkg in upgradable:
```

To

``
for pkg in []:
```

### Run do-release-upgrade

```
$ do-release-upgrade --allow-third-party
```


