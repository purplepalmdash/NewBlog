---
layout: post
title: "Ethernet Wakeup"
date: 2014-10-18 09:48
comments: true
categories: linux
---
### Purpose
I want to wake up my laotop via RaspberryPi, since Rpi's power consumption is extremely low, so this will greatly save the power for laptop.   
### Check Status
On laptop, type following command to see whether your ethernet card support Wake-On-LAN or not:    

```
[Trusty@~]$ sudo ethtool enp0s25 | grep Wake-on
	Supports Wake-on: pumbg
	Wake-on: g

```
The values define what activity to wake on: p (PHY activity), u (unicast activity), m (multicast activity), b (broadcast activity), a (ARP activity), and g (magic packet activity).We need g for WOL to work.     
### RaspberryPI Configuration
Make sure `wol` is installed, then you should know the target PC's ipaddress and mac address.     
Wakeup the remote machine via:    

```
$ wol -i 10.0.0.230 c8:xx:xx:xx:xx:xx

```
You could also set this command into a alias in ~/.bashrc.    
