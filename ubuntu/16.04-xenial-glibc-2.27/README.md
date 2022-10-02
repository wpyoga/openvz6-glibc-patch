# Building and installing glibc 2.27 on Ubuntu 16.04 LTS Xenial

## Upgrade all packages

First, upgrade all system packages.

Some questions will be asked, just keep to the default answers and it's usually fine.

## Add xenial-backports and bionic sources repositories

/etc/apt/sources.list.d/backports.list
```
deb http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse
```

/etc/apt/sources.list.d/bionic-src.list
```
deb-src http://archive.ubuntu.com/ubuntu bionic main restricted universe
deb-src http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe
deb-src http://archive.ubuntu.com/ubuntu bionic-security main restricted universe
```

```console
$ sudo apt update
```

## Install debian build tools and glibc build dependencies

```console
$ sudo apt install build-essential devscripts debhelper/xenial-backports bison rdfind symlinks systemtap-sdt-dev libselinux1-dev gcc-multilib g++-multilib libgd-dev libaudit-dev libcap-dev
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
$ patch -p0 < glibc-2.27-gcc-5.diff
$ patch -p0 < glibc-2.27-skip-tests.diff
$ sh glibc-2.27-patch-changelog-xenial.sh
```

The resulting binary packages will have the epoch version of 999. This makes apt
think that the packages are newer than any package updated on official Ubuntu
repositories, so they won't be mistakenly replaced by official Ubuntu packages.

You can upgrade to Ubuntu 18.04 Bionic and glibc packages will not be replaced.


## Build the packages

```console
( cd glibc-2.27 && dpkg-buildpackage -rfakeroot -b -d )
```

## Stage the packages

```
$ sudo mkdir -p /var/lib/libc6-openvz6/xenial-glibc-2.27
$ sudo chown myuser: /var/lib/libc6-openvz6/xenial-glibc-2.27
$ mv -i *.deb *.udeb *.changes /var/lib/libc6-openvz6/xenial-glibc-2.27
$ cd /var/lib/libc6-openvz6/xenial-glibc-2.27
$ apt-ftparchive packages . >Packages
$ apt-ftparchive release . >Release
```

## Upgrade to glibc 2.27

/etc/apt/sources.list.d/xenial-glibc-2.27.list
```
deb [trusted=yes] file:/var/lib/libc6-openvz6 xenial-glibc-2.27/
```

```
$ sudo apt update
$ sudo apt upgrade
```

