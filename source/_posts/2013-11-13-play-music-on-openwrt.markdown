---
layout: post
title: "Play Music On OpenWRT"
date: 2013-11-13 13:53
comments: true
categories: Linux OpenWRT
---
1\. Install usbutils, this will enable you to use lsusb to detect your usb equipments. 

```
	$ opkg install usbutils
```

2\. Use lsusb to detect your usb audio card. 

```
	# root@OpenWrt:~# lsusb
	Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	Bus 001 Device 002: ID 1a40:0101 TERMINUS TECHNOLOGY INC. USB-2.0 4-Port HUB
	Bus 001 Device 003: ID 0781:557c SanDisk Corp. 
	Bus 001 Device 004: ID 0424:2507 Standard Microsystems Corp. 
	Bus 001 Device 005: ID 0e5c:6441 Bitland Information Technology Co., Ltd C-Media Sound Device
	Bus 001 Device 006: ID 0e5c:6119 Bitland Information Technology Co., Ltd remote receive and control device
```

Now we will see the C-Media Sound Device has been detected in our own openwrt equipment. 
3\. Install usb audio kernel support modules: 

```
	$ opkg install kmod-usb-audio
```

4\. Install madplay for playing audio files:

```
	$ opkg install madplay
```

5\. For configuring the sound, install alsa-utils.

```
	$ opkg install alsa-utils
```

6\. Install madplayer for playing mp3

```
	$ opkg install madplayer
```

When Playing mp3, the cpu usage is only around 20%, and we can satisfy the volumn using alsamixer. 
