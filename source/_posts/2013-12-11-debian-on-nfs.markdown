---
layout: post
title: "Debian on NFS"
date: 2013-12-11 17:25
comments: true
categories: Linux Beaglebone
---
Install some packages:

```
	$ apt-get install usbutils alsa-base

```
Use lsusb to view the installed usb equipments:

```
	Bus 001 Device 006: ID 0e5c:6441 Bitland Information Technology Co., Ltd C-Media Sound Device

```
Install modules to the filesystem, since our newly-installed filesytem doesn't contains the necessary modules:

```
	$ pwd
	/media/x/bbBlack/38/linux-dev/deploy

```
Copy the firmware tar package and modules tar package to the nfs root directory

```
	$ tar xzvf 3.8.13-bone30-modules.tar.gz  -C ./
	$ tar xzvf ./3.8.13-bone30-firmware.tar.gz -C  ./lib/firmware/

```
Reboot and Use aplay to view the installed sound card:

```
	root@arm:/# aplay -l
	**** List of PLAYBACK Hardware Devices ****
	card 0: Black [TI BeagleBone Black], device 0: HDMI nxp-hdmi-hifi-0 []
	  Subdevices: 1/1
	  Subdevice #0: subdevice #0
	card 1: U0xe5c0x6441 [USB Device 0xe5c:0x6441], device 0: USB Audio [USB Audio]
	  Subdevices: 0/1
	  Subdevice #0: subdevice #0

```
Edit a new asound.conf, which will enable the system to use the usb audio as the default sound card:

```
	root@arm:/# cat /etc/asound.conf
	pcm.!default { 
	type hw 
	card 1
	#device 0 
	}
	ctl.!default { 
	type hw 
	card  1
	#device 0 
	}

```
Now you can use the mplayer to enjoy the sound from the console.     	
If you want to grant the right to the ordinary user, Just use acl: 

```
	 setfacl -m u:debian:rw /dev/snd/*

```
Now the user "debian" could also listen the music from the console. 
	

