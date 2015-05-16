---
layout: post
title: "BeagleBone boot from NFS"
date: 2013-12-10 09:10
comments: true
categories: Linux Beaglebone
---
###Building Preparation
Create a new directory for stroing all of the items related to beaglebone. 

```
	cd /media/nfs/
	mkdir beaglebone
	cd beaglebone/

```
Download the cross-compiler from linaro toolchain binary website. And add it to the environment variables. 

```
	wget -c https://launchpad.net/linaro-toolchain-binaries/trunk/2013.10/+download/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz
	tar xJf gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz
	export CC=`pwd`/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux/bin/arm-linux-gnueabihf-
	# Test the cross-compiler
	${CC}gcc --version

```
Checkout the U-boot:

```
	git clone git://git.denx.de/u-boot.git
	cd u-boot/
	git checkout v2013.10 -b tmp

```
Patching U-boot:

```
	wget https://raw.github.com/eewiki/u-boot-patches/master/v2013.10/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
	patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch

```
Configure and compile the U-boot:

```
	make ARCH=arm CROSS_COMPILE=${CC} distclean
	make ARCH=arm CROSS_COMPILE=${CC} am335x_evm_config
	make ARCH=arm CROSS_COMPILE=${CC}

```
Checkout the kernel:

```
	git clone git://github.com/RobertCNelson/linux-dev.git
	cd linux-dev
	git checkout origin/am33x-v3.12 -b tmp

```
Now we got our kernel and U-boot available. The next step is to build a filesystem:

```
	wget -c https://rcn-ee.net/deb/minfs/raring/ubuntu-13.04-minimal-armhf-2013-08-25.tar.xz

```

Prepare the mmc card. 

```
	export DISK=/dev/mmcblk0
	[Trusty@XXXyyy beaglebone]$ sudo dd if=/dev/zero of=${DISK} bs=1M count=16
	16+0 records in
	16+0 records out
	16777216 bytes (17 MB) copied, 4.84877 s, 3.5 MB/s 

```
Use sfdisk for creating the partition layout.

```
	sudo sfdisk --in-order --Linux --unit M ${DISK} <<-__EOF__
	1,48,0xE,*
	,,,-
	__EOF__

```
Format Partitions:

```
	sudo mkfs.vfat -F 16 ${DISK}p1 -n boot
	sudo mkfs.ext4 ${DISK}p2 -L rootfs

```
Install Bootloader to the 1st partition of mmc card. 

```
	[Trusty@XXXyyy beaglebone]$ sudo mkdir -p /media/boot/
	[Trusty@XXXyyy beaglebone]$ sudo mkdir -p /media/rootfs/
	[Trusty@XXXyyy beaglebone]$ sudo mount ${DISK}p1 /media/boot/
	[Trusty@XXXyyy beaglebone]$ sudo mount ${DISK}p2 /media/rootfs/
	[Trusty@XXXyyy beaglebone]$ sudo cp -v ./u-boot/MLO /media/boot/
	‘./u-boot/MLO’ -> ‘/media/boot/MLO’
	[Trusty@XXXyyy beaglebone]$ sudo cp -v ./u-boot/u-boot.img /media/boot/
	‘./u-boot/u-boot.img’ -> ‘/media/boot/u-boot.img’

	[Trusty@XXXyyy linux-dev]$ vim uEnv.txt
	[Trusty@XXXyyy linux-dev]$ sudo cp -v ./uEnv.txt /media/boot/
	‘./uEnv.txt’ -> ‘/media/boot/uEnv.txt’

```

Copy Kernel:

```
	[Trusty@XXXyyy beaglebone]$ sudo cp -v ./linux-dev/deploy/3.12.4-bone9.zImage /media/boot/zImage
	‘./linux-dev/deploy/3.12.4-bone9.zImage’ -> ‘/media/boot/zImage’

```
Copy Root File System:

```
	sudo tar xfvp ./ubuntu-13.04-minimal-armhf-2013-08-25/armhf-rootfs-ubuntu-raring.tar -C /media/rootfs/
Installation of kernel and configuration of the filesystem.
	sudo cp -v ./linux-dev/deploy/3.12.4-bone9.zImage /media/boot/zImage
	sudo mkdir -p /media/boot/dtbs/
	sudo tar xfov ./linux-dev/deploy/3.12.4-bone9-dtbs.tar.gz -C /media/boot/dtbs/
	sudo tar xfv ./linux-dev/deploy/3.12.4-bone9-firmware.tar.gz  -C /media/rootfs/lib/firmware/
	sudo tar xfv ./linux-dev/deploy/3.12.4-bone9-modules.tar.gz -C /media/rootfs/
	sudo vim /media/rootfs/etc/fstab
	sudo vim /media/rootfs/etc/network/interfaces 
	sudo vim /media/rootfs/etc/udev/rules.d/70-persistent-net.rules
	sudo vim /media/rootfs/etc/inittab
	sudo vim /media/rootfs/etc/init/serial.conf
	sudo umount /media/rootfs/
	sudo umount /media/boot/

```


