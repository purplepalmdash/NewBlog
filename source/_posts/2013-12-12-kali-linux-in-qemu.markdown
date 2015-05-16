---
layout: post
title: "KALI Linux in Qemu"
date: 2013-12-12 17:32
comments: true
categories: Linux Qemu
---
Download the iso from kali website[http://www.kali.org/downloads/](http://www.kali.org/downloads/):

```
	$ wget http://cdimage.kali.org/kali-images/kali-1.0.5/kali-linux-1.0.5-i386.iso

```
Create qemu img file:

```
	$ qemu-img create -f qcow2 kali.qcow2 30G
	Formatting 'kali.qcow2', fmt=qcow2 size=32212254720 encryption=off cluster_size=65536 lazy_refcounts=off 
Run installation. Here we use the run-qemu script which has been generated before under the same directory:
	[Trusty@DashArch kali]$ ./run-qemu -hda ./kali.qcow2 -boot d -cdrom /media/nfs/iso/kali-linux-1.0.5-i386.iso  -m 1024 -enable-kvm -usb

```
Choose "Graphic Install" because currently we are not familiar with this brand new distribution.     
Command for startup the sytem is:

```
	[Trusty@DashArch kali]$ ./run-qemu -hda ./kali.qcow2 -boot d -cdrom /media/nfs/iso/kali-linux-1.0.5-i386.iso  -m 1024 -enable-kvm -usb

```
After installation finished, run "sudo apt-get update" and "sudo apt-get upgrade" to update your system to the newest version. 

