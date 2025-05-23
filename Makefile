initramfs:
	rm -f initramfs/initramfs.cpio
	cd initramfs && find . -print0 | cpio --null -ov --format=newc > initramfs.cpio && cd -
	scp initramfs/initramfs.cpio kalray:/mnt/ssd/altc/workspace/build_buildroot/build_conf_mppa/images/rootfs.cpio
	ssh kalray make -C /mnt/ssd/altc/workspace/build_buildroot/build_conf_mppa linux-rebuild

rootfs:
	rm -f rootfs.ext4
	truncate -s 1G rootfs.ext4
	mkfs.ext4 rootfs.ext4
	sudo mount -oloop rootfs.ext4 /mnt
	sudo cp -a rootfs/. /mnt/.
	sudo umount /mnt
	e2fsck -f rootfs.ext4
	resize2fs -M rootfs.ext4
	scp rootfs.ext4 kalray:/tmp/

linux:
	rm -rf linux-lts
	mkdir linux-lts
	cp linux-lts*.apk linux-lts/linux.tar.gz
	cd linux-lts ; tar xzf linux.tar.gz
	scp linux-lts/boot/vmlinuz-lts kalray:/tmp/alpine/

.PHONY: rootfs
.PHONY: initramfs
