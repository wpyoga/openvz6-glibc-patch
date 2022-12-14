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

Install `update-manager-core` and use `do-release-upgrade`. During the upgrade, accept new
config files unless you have customized it previously.

After the upgrade, re-enable third-party repositories, including our local glibc repo.
Then do an `apt update` and run `ubuntu-support-status --show-unsupported` to see which
packages are no longer supported (no security updates).

The unsupported packages are safe to remove, except for the following:
- glibc-related packages
- packages needed to build the next version of glibc

Starting from Focal, `ubuntu-support-status` is not available anymore. Instead, run
`ubuntu-security-status --unavailable` to get a list of unavailable packages, which means
that those packages may have been leftover from a previous install, and obsolete.


## Upgrade 16.04 Xenial to 18.04 Bionic

1. Download, patch, build, and install glibc 2.27
1. Upgrade the system to 18.04 Bionic
1. Patch, build, and install glibc 2.27 using another set of patches

After the system upgrade, you can remove the unsupported packages except for `dialog`,
which is sometimes needed by `apt`.


## Upgrade 18.04 Bionic to 20.04 Focal

Ubuntu 20.04 Focal comes with glibc 2.31 .

1. Download, patch, build, and install glibc 2.31
1. Upgrade the system to 20.04 Focal
1. Patch, build, and install glibc 2.31 using another set of patches

After the system upgrade, add your main user account to the `systemd-journal` group,
so that the systemd logs are available without using sudo.


## Upgrade 20.04 Focal to 22.04 Jammy

Upgrading from Focal to Jammy requires some preparation:

1. Create the file `/etc/systemd/system/service.d/99-openvz.conf` to disable some
   systemd features. Due to missing features in the OpenVZ 6 kernel, we need to disable
   these features to prevent errors in some services, including systemd-logind,
   which would affect ssh, sudo, and normal console login.
    ```
    [Service]
    ProtectSystem=false
    ProtectKernelModules=false
    ```

1. Reboot the system to apply the overrides. In particular, this enables /usr merge,
   otherwise there will be some mounts in `/lib/modules` that causes /usr merge to fail.

Ubuntu 22.04 Jammy comes with glibc 2.35 .

1. Download, patch, build, and install glibc 2.35
1. Upgrade the system to 22.04 Jammy
1. Patch, build, and install glibc 2.35 using another set of patches

Reboot after installing glibc, because there seem to be errors.


## Notes

By default,

- We don't build the packages `locales`, `locales-all`, `multiarch-support`, and `nscd`.
  These packages are independent of the kernel, so we can just use the official packages.

- We don't build the udeb package, since it's only used for the debian installer.

- We don't build the debug (dbg, dbgsym) and profiling (prof) packages. Most users
  don't need those anyway.

- We don't build multi-arch packages.

