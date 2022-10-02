#!/bin/sh

# glibc (2.27-3ubuntu1.6) bionic; urgency=medium
head -n1 glibc-2.27/debian/changelog | grep -wq bionic
if [ $? -ne 0 ]; then
  echo Changelog already patched.
  exit 0
fi

echo Patching glibc-2.27/debian/changelog

TEMP1=$(mktemp)
TEMP2=$(mktemp)

cat >$TEMP1 <<EOF
glibc (2.27-openvz6+ubuntu16.04+3ubuntu1.6) UNRELEASED; urgency=medium

  * Build on Xenial on OpenVZ 6

 -- William Poetra Yoga <william.poetra@gmail.com>  Sat, 1 Oct 2022 10:42:58 +0700

EOF

cat $TEMP1 glibc-2.27/debian/changelog >$TEMP2
cat $TEMP2 >glibc-2.27/debian/changelog
rm $TEMP1 $TEMP2

