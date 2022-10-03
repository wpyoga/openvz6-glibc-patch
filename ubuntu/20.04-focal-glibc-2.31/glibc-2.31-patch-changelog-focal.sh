#!/bin/sh

# glibc (2.31-0ubuntu9.9) focal; urgency=medium
head -n1 glibc-2.31/debian/changelog | grep -wq focal
if [ $? -ne 0 ]; then
  echo Changelog already patched.
  exit 0
fi

echo Patching glibc-2.31/debian/changelog

TEMP1=$(mktemp)
TEMP2=$(mktemp)

cat >$TEMP1 <<EOF
glibc (2.31-openvz6+ubuntu20.04+0ubuntu9.9) UNRELEASED; urgency=medium

  * Build on Focal on OpenVZ 6

 -- William Poetra Yoga <william.poetra@gmail.com>  Mon, 3 Oct 2022 21:51:37 +0700

EOF

cat $TEMP1 glibc-2.31/debian/changelog >$TEMP2
cat $TEMP2 >glibc-2.31/debian/changelog
rm $TEMP1 $TEMP2

