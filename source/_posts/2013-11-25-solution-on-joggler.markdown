---
layout: post
title: "Solution On Joggler"
date: 2013-11-25 09:30
comments: true
categories: Linux Joggler
---
###Hardware
Joggler     
Intel(R) Atom(TM) CPU Z520   @ 1.33GHz  Dual Core    
MemTotal:         504480 kB     
Harddisk: 500G External USB.    

###System and Software
Download the Ubuntu Base/Server 12.04 LTS (Precise) (Joggler Image v1.4 - 09/04/2013) from the     
[http://joggler.exotica.org.uk/ubuntu/](http://joggler.exotica.org.uk/ubuntu/)
From the ubuntu website we know 12.04 LTS will supported to 2017, I think that fits my needs.     
Unzip the download image:

```
	gunzip ubuntu_base_12.04-v1.4-ext4.img.gz
	dd if=./ubuntu_base_12.04-v1.4-ext4.img of=/dev/sdc bs=1M

```
The use this external usb disk for booting up the joggler. After joggler has been booted up, install coresponding packages.     

###Prevent Hard disk from hiberating
Add following lines to crontab -e

```
	*/4 * * * * fdisk -l /dev/uba>/dev/null && echo abc>/root/done.txt

```
	
