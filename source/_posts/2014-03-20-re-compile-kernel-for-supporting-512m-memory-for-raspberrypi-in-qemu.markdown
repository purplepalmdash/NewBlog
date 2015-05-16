---
layout: post
title: "Re-compile Kernel For Supporting 512M Memory For RaspberryPI In Qemu"
date: 2014-03-20 09:43
comments: true
categories: RaspberryPI
---
###Cross Compiler Prepration
Get the cross-compiler from github:<br />

```
	[Trusty@XXXyyy tools]$ pwd
	/media/y/raspberryPI/tools
	[Trusty@XXXyyy tools]$ git clone git://github.com/raspberrypi/tools.git

```
Add the cross-compiler to system path:<br />

```
	export PATH="/media/y/raspberryPI/tools/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH"

```
Now input "arm-linux-g" + tab you will see the cross-compiler is ready.<br />
###Prepare the kernel
Get the kernel source from github:<br />

```
	git clone git://github.com/raspberrypi/linux.git

```
Now we need to get the patches for supporting the raspberryPI, Torlus has done the patches which could also be downloaded from github:<br />


Now we need to configure the kernel:<br />

```
	cd linux
	make ARCH=arm versatile_defconfig

```


NO, I MADE A MISTAKE, IT SHOULDN'T COMPILE KERNEL, SHOULD COMPILE QEMU!!!

###Compile qemu
Get the modified qemu branch from github:<br />

```
	git clone git://github.com/Torlus/qemu.git

```
Switch to 'rpi' branch:<br />

```
	git fetch origin
	git branch -v -a # List the available branches.
	git checkout -b raspberry origin/rpi	# Checkout the origin/rpi to local raspberry
	git fetch
	git checkout raspberry

```
Begin to configure qemu, notice we have to use python2 for configuring the qemu:<br />

```
	workon venv2
	./configure --help
	./configure --target-list="arm-softmmu arm-linux-user" --enable-sdl 

```
Now begin to make the qemu, use -j8 for speeding up, adjust the number according to your own machine:<br />

```
	make -j8

```
Now under the following directory you will get the qemu-system-arm:<br />

```
	$ pwd
	/media/y/raspberryPI/qemu/arm-softmmu

```
Get the kernel.img from the SD image. <br />

###Use the compiled qemu for running
We have to change the scripts for running the qemu:<br />

```
	/media/y/raspberryPI/qemu/arm-softmmu/qemu-system-arm -net nic,macaddr=$macaddr -net user -kernel kernel.img -cpu arm1176 -m 512 -M raspi -no-reboot -serial stdio -append "rw earlyprintk loglevel=8 panic=120 keep_bootcon rootwait dma.dmachans=0x7f35 bcm2708_fb.fbwidth=1024 bcm2708_fb.fbheight=768 bcm2708.boardrev=0xf bcm2708.serial=0xcad0eedf smsc95xx.macaddr=B8:27:EB:D0:EE:DF sdhci-bcm2708.emmc_clock_freq=100000000 vc_mem.mem_base=0x1c000000 vc_mem.mem_size=0x20000000  dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait" -sd 2014-01-07-wheezy-raspbian.img  -device usb-kbd -device usb-mouse -usbdevice net 

```
Now we can run the raspberryPI in QEMU with 512MB memory, but, the network is still unavailable. 

