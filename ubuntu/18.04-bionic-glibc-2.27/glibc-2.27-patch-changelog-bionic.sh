#!/bin/sh

TEMP1=$(mktemp)
TEMP2=$(mktemp)

# glibc (2.27-3ubuntu1.6) bionic; urgency=medium
head -n1 glibc-2.27/debian/changelog | grep -wq bionic
if [ $? -ne 0 ]; then
  echo Changelog already prepended.
  exit 0
fi

cat >$TEMP1 <<EOF
glibc (999:2.27-3ubuntu1.6bionic1) UNRELEASED; urgency=medium

  * Build on Bionic on OpenVZ 6

 -- William Poetra Yoga <william.poetra@gmail.com>  Sat, 2 Oct 2022 14:14:14 +0700

EOF

cat $TEMP1 glibc-2.27/debian/changelog >$TEMP2
cat $TEMP2 >glibc-2.27/debian/changelog
rm $TEMP1 $TEMP2

