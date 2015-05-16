---
layout: post
title: "Compile Linux kernel for Beaglebone"
date: 2013-11-14 10:18
comments: true
categories: Linux Beaglebone
---
###SourceCode Preparation
1\. Get the latest code of beaglebone kernel:

```
	git clone git://github.com/RobertCNelson/linux-dev.git
```

2\. Check for your cross-compiler:

```
	$ which arm-linux-gnueabi-gcc
	/media/y/embedded/gcc-linaro-arm-linux-gnueabi-2012.02-20120222_linux/bin/arm-linux-gnueabi-gcc
```

3\. Start a new branch

```
	$ git checkout origin/am33x-v3.2 -b am33x-v3.2
	Branch am33x-v3.2 set up to track remote branch am33x-v3.2 from origin.
	Switched to a new branch 'am33x-v3.2'
```

Since the latest kernel has been moved 3.12, we have to checkout am33x-v3.12

```
	$ git checkout origin/am33x-v3.12 -b am33x-v3.12
```

You also have to manually download the latest kernel source code from github:

```
	$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
```

###Configure everything before compilation
Edit the system.sh file

```
	$ cp system.sh.sample system.sh
```

The system.sh should have following lines:

```
	echo "Using: Cross Compiler"
	CC=arm-linux-gnueabi-
	##For TI: OMAP3/4/AM35xx
	ZRELADDR=0x80008000
	#LINUX_GIT=/home/user/linux-stable/
	LINUX_GIT=/media/x/bbBlack/linux/git/linux-stable/
```

Then run ./build_kernel.sh to see your kernel is under compiling, you will be prompted to asked "make menuconfig", choose whatever you want.Wait patiently until all of your compilation is done.    
###Install kernel
Edit the destination for your installation, edit the file "system.sh":

```
	MMC=/dev/mmcblk0 
	# or whatever you found in your own system.
```

Then you simply input ./tools/install_kernel.sh, you will be asked some questions, answer then and your kernel will be installed to your sd card. Now use the SD card for booting system, you will get a brand-new system. 
###Install Filesystem
Download the pre-configured filesystems from:

```
	# For example, download the quantal related image, that's 12.10.
	$ wget http://rcn-ee.net/deb/rootfs/quantal/ubuntu-12.10-console-armhf-2013-07-22.tar.xz
	$ unxz ubuntu-12.10-console-armhf-2013-07-22.tar.xz
	$ tar xvf ubuntu-12.10-console-armhf-2013-07-22.tar
```

Then insert your SD card, simply input:

```
	# take BeagleBoneBlack for example:
	$ sudo ./setup_sdcard.sh --mmc /dev/sdX --uboot bone
```

After setup SD card, using the newly configured SD card for booting up the system, you will get the new system running the pre-configured rootfs. 

