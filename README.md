# Alpine Linux on kvx bootstrap

This contains the Containerfile used to generate an Alpine environment that can be used to run the bootstrap script from aports: https://git.alpinelinux.org/aports/tree/scripts/bootstrap.sh

This needs to run on an Alpine distro because it uses Alpine packaging/build tools.

## How to use this

```bash
$ git clone https://github.com/fallen/alpine-on-kvx
$ cd alpine-on-linux
$ podman build .
```

The podman build command generates an Alpine image and ends up printing a sha1 like `--> ce02e1ac49d`
Then run this to run a container based on the generated image:

```bash
$ podman run -ti ce02e1ac49d sh
```

Start the bootstrap process by cross-compiling basic Alpine packages for kvx:

```bash
/ $ cd ~/aports/scripts/
~/aports/scripts $ ./bootstrap.sh kvx
```

Then generate rootfs:

```bash
cd ~/packages/main/kvx
echo "file:///home/yann/packages/main" > ~/repositories
doas ~/aports/scripts/genrootfs.sh -r ~/repositories -a kvx -o $PWD/alpine-kvx.tar.gz fortify-headers-1.1-r3.apk linux-headers-5.16.20-r0.apk musl-1.2.3-r2.apk libc-dev-0.7.2-r5.apk pkgconf-1.9.5-r0.apk zlib-1.2.13-r2.apk openssl-3.1.1-r1.apk ca-certificates-20230506-r0.apk libmd-1.1.0-r0.apk gmp-6.2.1-r3.apk mpfr4-4.2.0-r3.apk mpc1-1.3.1-r1.apk isl26-0.26-r1.apk libucontext-1.2-r2.apk binutils-4.13.0-r12.apk gcc-12.2.1_git20220924-r10.apk libbsd-0.11.7-r2.apk busybox-1.36.1-r3.apk busybox-binsh-1.36.1-r3.apk file-5.44-r5.apk alpine-baselayout-3.4.3-r1.apk alpine-baselayout-data-3.4.3-r1.apk build-base-0.5-r3.apk  alpine-conf-3.16.2-r0.apk apk-tools-2.14.0-r5.apk busybox-extras-1.36.1-r3.apk busybox-extras-openrc-1.36.1-r3.apk busybox-ifupdown-1.36.1-r3.apk busybox-mdev-openrc-1.36.1-r3.apk busybox-openrc-1.36.1-r3.apk busybox-static-1.36.1-r3.apk busybox-suid-1.36.1-r3.apk util-linux-2.39.1-r0.apk  util-linux-misc-2.39.1-r0.apk util-linux-openrc-2.39.1-r0.apk fakeroot-1.31-r3.apk abuild-3.11.20-r0.apk
```

Then generate initramfs:

```bash
doas apk add mkinitfs
mkdir rootfs
cp alpine-kvx.tar.gz rootfs/
cd rootfs
tar xzf alpine-kvx.tar.gz
rm alpine-kvx.tar.gz
cp /home/yann/sysroot-kvx/etc/apk/keys/* $PWD/etc/apk/keys/
cd ..
mkinitfs -o alpine-kvx-initramfs -n -k -b $PWD/rootfs
```

Run it via qemu:

```bash
qemu-system-kvx -M mppa-coolidge,virtio-mmio=on -m 4G -nographic -kernel /mnt/ssd/altc/workspace/build_buildroot/build_conf_mppa/images/vmlinux --append "nr_cpus=1 console=ttyS0 root=/dev/vda" -drive file=/tmp/alpine/rootfs.ext4,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -device virtio-net-device,netdev=net0 -netdev user,id=net0,net=192.168.252.0/24,dhcpstart=192.168.252.1,hostfwd=tcp::2222-:22,restrict=no
```

kvx package build order:
```
bzip2
lua5.2
perl (without testsuite)
```

k200lp cmdline: earlycon norandmaps console=ttyS0,115200 root=/dev/mmcblk0 initrd=0x1100
00000,6105272

Mount repository into podman:
podman run -ti --mount type=bind,source=$HOME/packages,destination=/mnt localhost/alpine_kvx_built3 sh

Re-generate APKINDEX from podman x86:
/mnt/main/kvx # apk index --arch kvx --progress -d "Alpine kvx repositor
y" -x APKINDEX.tar.gz --allow-untrusted --merge -o APKINDEX.tar.gz *.apk

SIGN APKINDEX:
/mnt/main/kvx # abuild-sign -k /home/yann/.abuild/-64bd12af.rsa -p /etc/
apk/keys/-64bd12af.rsa.pub   APKINDEX.tar.gz
