#!/bin/sh

rm *.buildinfo *.changes

rm -r /var/lib/libc6-openvz6/jammy-glibc-2.35
mkdir -p /var/lib/libc6-openvz6/jammy-glibc-2.35
mv -i *.deb /var/lib/libc6-openvz6/jammy-glibc-2.35
cd /var/lib/libc6-openvz6/jammy-glibc-2.35
apt-ftparchive packages . >Packages
apt-ftparchive release . >Release

