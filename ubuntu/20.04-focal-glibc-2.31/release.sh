#!/bin/sh

rm *.buildinfo *.changes

rm -r /var/lib/libc6-openvz6/focal-glibc-2.31
mkdir -p /var/lib/libc6-openvz6/focal-glibc-2.31
mv -i *.deb /var/lib/libc6-openvz6/focal-glibc-2.31
cd /var/lib/libc6-openvz6/focal-glibc-2.31
apt-ftparchive packages . >Packages
apt-ftparchive release . >Release

