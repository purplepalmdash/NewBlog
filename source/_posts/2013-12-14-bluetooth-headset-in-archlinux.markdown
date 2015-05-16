---
layout: post
title: "Bluetooth headset in ArchLinux"
date: 2013-12-14 13:57
comments: true
categories: Linux Bluetooth
---
I have a Nokia bluetooth headset BH-105,and a bluetooth usb dongle. And I want to connect them together. Following are the steps.     
###Software Preparation
On ArchLinux, Install "bluez" and "bluez-utils"

```
	$ sudo pacman -S bluez bluez-utils
	$ sudo systemctl start bluetooth && sudo systemctl enable bluetooth

```

