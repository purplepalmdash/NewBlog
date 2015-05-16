---
layout: post
title: "Enable audio in BeagleBone Black"
date: 2013-12-09 16:10
comments: true
categories: Linux Embedded
---
The usb sound card which I want to enable is a legend hub.     

![legendsoundcard](/images/legendsoundcard.jpg)

###Package Installation
Install necessary packages:

```
	$ sudo apt-get update &&  sudo apt-get upgrade
	$ sudo apt-get install vim mplayer alsa-base 

```
	
###Hardware Configuration
View the sound card information:

```
	root@arm:~# lsusb
	Bus 001 Device 029: ID 0424:2507 Standard Microsystems Corp. 
	Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	Bus 001 Device 030: ID 0e5c:6441 Bitland Information Technology Co., Ltd C-Media Sound Device
	Bus 001 Device 113: ID 0e5c:6119 Bitland Information Technology Co., Ltd remote receive and control device

```
C-Media is the sound card, we gonna configure this card.     
list all of the loaded modules which contains the sound: 

```
	root@arm:~# lsmod | grep snd
	snd_usb_audio         111095  0 
	snd_hwdep               5925  1 snd_usb_audio
	snd_usbmidi_lib        17765  1 snd_usb_audio
	snd_rawmidi            21065  1 snd_usbmidi_lib
	snd_seq_device          6582  1 snd_rawmidi

```
List all of the loaded sound modules and there order: 

```
	root@arm:~# cat /proc/asound/cards   
	 0 [Black          ]: TI_BeagleBone_B - TI BeagleBone Black
	                      TI BeagleBone Black
	 1 [U0xe5c0x6441   ]: USB-Audio - USB Device 0xe5c:0x6441
	                      USB Device 0xe5c:0x6441 at usb-musb-hdrc.1.auto-1.1, full speed

```
###Sound Configure
See how many cards could be viewed via system:

```
	root@arm:~# aplay -l
	**** List of PLAYBACK Hardware Devices ****
	card 0: Black [TI BeagleBone Black], device 0: HDMI nxp-hdmi-hifi-0 []
	  Subdevices: 1/1
	  Subdevice #0: subdevice #0
	card 1: U0xe5c0x6441 [USB Device 0xe5c:0x6441], device 0: USB Audio [USB Audio]
	  Subdevices: 0/1
	  Subdevice #0: subdevice #0

```
Then Configure the usb sound card to be the default(System Wide). 

```
	root@arm:~# cat /etc/asound.conf 
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
Now you can listen to the music via usb card.    
For saving the current alsa configuration information:

```
	$ sudo chmod -R 777 /var/lib/alsa/
	$ alsactl store

```
