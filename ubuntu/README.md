## Ubuntu on OpenVZ 6

This project only supports LTS-to-LTS version upgrades.

In general, what we do is:

1. Build the next release's glibc
1. Upgrade to the next release
1. Build the same glibc again

The first build is only there to facilitate the upgrade to the next release. After upgrading
the system, we need to build the same glibc again with the newer toolchain in order to get
all the new features.


## glibc versions that come with each Ubuntu LTS version

- Ubuntu 16.04 LTS Xenial: glibc 2.23
- Ubuntu 18.04 LTS Bionic: glibc 2.27
- Ubuntu 20.04 LTS Focal: glibc 2.31
- Ubuntu 22.04 LTS Jammy: glibc 2.35


## LTS version upgrades

Install update-manager-core and use `do-release-upgrade`. During the upgrade, accept new
config files unless you have customized it previously.

After the upgrade, re-enable third-party repositories, including our local glibc repo.
Then do an `apt update` and run `ubuntu-support-status --show-unsupported` to see which
packages are no longer supported (no security updates).

The unsupported packages are safe to remove, except for the following:
- glibc-related packages
- packages needed to build the next version of glibc

Starting from Jammy, `ubuntu-support-status` is not available anymore. Instead, run
`ubuntu-security-status --unavailable` to get a list of unavailable packages, which means
that those packages may have been leftover from a previous install, and obsolete.


## Upgrade 16.04 Xenial to 18.04 Bionic

1. Download, patch, build, and install glibc 2.27
1. Upgrade the system to 18.04 Bionic
1. Patch, build, and install glibc 2.27 using another set of patches

After the system upgrade, these packages should be safe to remove:
cpp-5 e2fsprogs-l10n finger gcc-4.8-base gcc-5 gcc-5-base gcc-6-base libasan2 libgcc-5-dev
module-init-tools libisl15 liblua5.1-0 libmpx0 libustr-1.0-1
debconf-utils lzma procinfo makedev


## Upgrade 18.04 Bionic to 20.04 Focal

Ubuntu 20.04 Focal comes with glibc 2.31 .

1. Download, patch, build, and install glibc 2.31
1. Upgrade the system to 20.04 Focal
1. Patch, build, and install glibc 2.31 using another set of patches


## Upgrade 20.04 Focal to 22.04 Jammy

Upgrading from Focal to Jammy requires some preparation:

1. Disable some systemd features by creating a file
   `/etc/systemd/system/service.d/99-openvz.conf`
    ```
    [Service]
    ProtectSystem=false
    ProtectKernelModules=false
    ```
1. Help usrmerge migration by moving `/lib/modules` to `/usr/lib/modules`
    ```
    $ sudo mv /lib/modules /usr/lib/modules
    $ sudo ln -s /usr/lib/modules /lib/
    ```

Ubuntu 22.04 Jammy comes with glibc 2.35 .

1. Download, patch, build, and install glibc 2.35
1. Upgrade the system to 22.04 Jammy
1. Patch, build, and install glibc 2.35 using another set of patches

