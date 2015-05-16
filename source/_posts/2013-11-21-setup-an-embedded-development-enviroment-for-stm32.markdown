---
layout: post
title: "Setup an embedded development enviroment for STM32"
date: 2013-11-21 20:50
comments: true
categories: Linux Eclipse stm32
---
###Download the toolchain
We should download the toolchain from the ARM employee maintained website, the download address is located at: [https://launchpad.net/gcc-arm-embedded](https://launchpad.net/gcc-arm-embedded), use following command:

```
	$ wget https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q3-update/+download/gcc-arm-none-eabi-4_7-2013q3-20130916-linux.tar.bz2

```
untar the downloaded package and then add it to your system path, my solution is directly add some alias into ~/.bashrc:

```
	### Add Cross_Compiler for eclipse based stm32
	#export PATH="/media/y/embedded/cortex/gcc-arm-none-eabi-4_7-2013q3/bin:$PATH"
	alias setstm='export PATH="/media/y/embedded/cortex/gcc-arm-none-eabi-4_7-2013q3/bin:$PATH"'

```
###Eclipse Configuration
We have to install zylin for flashing the stm32 board. After installation, eclipse will be rebooted. 

![images/eclipseinstall.jpg](/images/eclipseinstall.jpg)

###OpenOCD
OpenOCD is a open-source hardware debugger.    

```
	community/openocd 0.7.0-2
	    Debugging, in-system programming and boundary-scan testing for embedded target devices
	[root@XXXyyy capscr]# pacman -S openocd

```
###Template prepration
Download the template from :

```
	$ git clone https://github.com/JorgeAparicio/bareCortexM.git

```

