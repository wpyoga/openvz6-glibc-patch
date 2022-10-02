This project only supports LTS-to-LTS version upgrades.

In general, what we do is:

1. Build the next release's glibc
1. Upgrade to the next release
1. Build the same glibc again

The first build is only there to facilitate the upgrade to the next release. After upgrading the system,
we need to build the same glibc again with the newer toolchain in order to get all the new features.


## glibc versions that come with each Ubuntu LTS version

- Ubuntu 16.04 LTS Xenial: glibc 2.23
- Ubuntu 18.04 LTS Bionic: glibc 2.27
- Ubuntu 20.04 LTS Focal: glibc 2.31
- Ubuntu 22.04 LTS Jammy: glibc 2.35


## LTS version upgrades

Install update-manager-core and use do-release-upgrade.


## Upgrade 16.04 Xenial to 18.04 Bionic

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

