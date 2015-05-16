---
layout: post
title: "Automatically Mount in ArchLinux"
date: 2014-04-16 16:56
comments: true
categories: Linux
---
Use udisk/udisk2/udiskie for automatically mount usb disks.     

```
	pacman -S udisk udisk2 udiskie

```
Add following line into the .xinitrc:    

```
	udiskie -2 --tray &

```
If you want to umount all media with the command:

```
	udiskie-umount -a

```
umount speicified disk partition:

```
	udiskie-umount /media/MY_USB_DRIVE

```
