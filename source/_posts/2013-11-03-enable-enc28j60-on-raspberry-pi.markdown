---
layout: post
title: "Enable enc28j60 on Raspberry PI"
date: 2013-11-03 10:40
comments: true
categories: Linux RaspberryPI
---
###Kernel Source Preparation
Install libncurses5-dev for make menuconfig

```
	$ sudo apt-get install libncurses5-dev
	$ sudo apt-get update && sudo apt-get upgrade -y
Get the source code and configure the kernel modules
	git clone --depth 1 https://github.com/raspberrypi/linux.git
	cd linux
	zcat /proc/config.gz >.config
	edit .config and enable
```

The Configuration image listed as following:

![kernelconfig](/images/kernelconfig.jpg "kernelconfig.jpg")

###Wiring Preparation

```
	ENC - RPi
	===============
	VCC - 3v3
	GND - GND
	CS - CE0 (gpio 8)
	SI - MOSI (gpio 10)
	SCK - SCKL (gpio 11)
	SO - MISO (gpio 9)
```

Rapsberry PI GPIO Description:    

![GPIOs](/images/RPi_P1_header.png "RPi_P1_header.png")

GPIOs:    

![GPIO](/images/GPIOs.png "GPIOs.png")

###Speedup compiling
Using cross-compiler:   
Resolve the cross-compiler issue:

```
	[root@XXXyyy lib]# cp libppl.so.13 libppl.so.12
	[root@XXXyyy lib]# pwd
	/usr/lib
```

The yaourt's cross-compiler is not ok, so we need to use official cross-compiler, download it from :

```
	$ git clone git://github.com/raspberrypi/tools.git
	#### Install crosscompiler for RaspberryPI ####
	$ export PATH="/media/x/vmware/rasp/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH"
```

Then you can use cross-compiler to compile your own kernel image and kernel modules.   

