#!/bin/sh

rm *.buildinfo *.changes

rm -r /var/lib/libc6-openvz6/bionic-glibc-2.27
mkdir -p /var/lib/libc6-openvz6/bionic-glibc-2.27
mv -i *.deb /var/lib/libc6-openvz6/bionic-glibc-2.27
cd /var/lib/libc6-openvz6/bionic-glibc-2.27
apt-ftparchive packages . >Packages
apt-ftparchive release . >Release

