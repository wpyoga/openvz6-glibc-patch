#!/bin/sh

# glibc (2.35-0ubuntu3.1) jammy; urgency=medium
head -n1 glibc-2.35/debian/changelog | grep -wq jammy
if [ $? -ne 0 ]; then
  echo Changelog already patched.
  exit 0
fi

echo Patching glibc-2.35/debian/changelog

TEMP1=$(mktemp)
TEMP2=$(mktemp)

cat >$TEMP1 <<EOF
glibc (2.35-openvz6+ubuntu22.04+0ubuntu3.1) UNRELEASED; urgency=medium

  * Build on Jammy on OpenVZ 6

 -- William Poetra Yoga <william.poetra@gmail.com>  Wed, 5 Oct 2022 11:35:02 +0700

EOF

cat $TEMP1 glibc-2.35/debian/changelog >$TEMP2
cat $TEMP2 >glibc-2.35/debian/changelog
rm $TEMP1 $TEMP2

