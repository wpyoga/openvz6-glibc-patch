OpenVZ 6 was a popular platform on which to offer cheap VPS services using container technology.
It was resource-efficient, and providers could scale up (read: oversell) really well.

It runs a single kernel that supports multiple containers. Each container runs on the same kernel and
is not able to modify the kernel at all.

However, OpenVZ 6 is really old, and its kernel (2.6.32) doesn't allow for newer distros to be installed,
mainly because of glibc incompatibility with older kernels.

This project aims to bring support of older kernels to newer distros. When using non-container solutions
like KVM, there is no such issue because the kernel can always be upgraded together with the distro.

Please note that this project is not fit for use in a production environment. It is for educational purposes only.

