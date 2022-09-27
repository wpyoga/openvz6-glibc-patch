This project only supports LTS-to-LTS version upgrades.

In general, what we do is:

1. Build the next release's glibc
1. Upgrade to the next release
1. Build the same glibc again

The first build is only there to facilitate the upgrade to the next release. After upgrading the system,
we need to build the same glibc again with the newer toolchain in order to get all the new features.


## Upgrade 16.04 Xenial to 18.04 Bionic

Ubuntu 16.04 Xenial comes with glibc 2.23, while Ubuntu 18.04 Bionic comes with glibc 2.27 .

1. Download, patch, build, and install glibc 2.27
1. Upgrade the system to 18.04 Bionic
1. Patch, build, and install glibc 2.27 using another set of patches


## Upgrade 18.04 Bionic to 20.04 Focal

Ubuntu 20.04 Focal comes with glibc 2.31 .

1. Download, patch, build, and install glibc 2.31
1. Upgrade the system to 20.04 Focal
1. Patch, build, and install glibc 2.31 using another set of patches


## Upgrade 20.04 Focal to 22.04 Jammy

Ubuntu 22.04 Jammy comes with glibc 2.35 .

1. Download, patch, build, and install glibc 2.35
1. Upgrade the system to 22.04 Jammy
1. Patch, build, and install glibc 2.35 using another set of patches

