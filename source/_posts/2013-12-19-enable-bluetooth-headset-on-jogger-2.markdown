---
layout: post
title: "Enable Bluetooth Headset on Jogger(2)"
date: 2013-12-19 09:11
comments: true
categories: Linux
---
Since trying to enable BT headset failed on Ubuntu12.04 Server, I decide to try xubuntu version. So I download the image from [http://joggler.exotica.org.uk/ubuntu/](http://joggler.exotica.org.uk/ubuntu/), then extract it to get the image.     
###Get the filesystem
Use fdisk to get the img layout

```
	root@joggler:/media/nfs/xubuntu# fdisk -l xubuntu_12.04-v1.4-ext4.img 
	                      Device Boot      Start         End      Blocks   Id  System
	xubuntu_12.04-v1.4-ext4.img1   *        2048      126975       62464    e  W95 FAT16 (LBA)
	xubuntu_12.04-v1.4-ext4.img2          126976      626687      249856   82  Linux swap / Solaris
	xubuntu_12.04-v1.4-ext4.img3          626688     7800831     3587072   83  Linux

```
So we can caculate the offset is 626688X512=320864256.     
Use following commands to copy the filesystem out to the actual disk:

```
	$ mount ./xubuntu_12.04-v1.4-ext4.img  -o offset=320864256 /mnt3/
	$ mount /dev/uba5 /mnt
	$ cp -ar /mnt3/* /mnt/

```
My disk layout is:     
![playout.jpg](/images/playout.jpg)
###Modification for bootup Xubuntu
####Add new item for grub: 
Get the disk labels:

```
	$ ls /dev/disk/by-label/
	Xubuntu  linux-boot  linux-root  linux-swap  mmc-boot  mmc-root

```
The newly added label "Xubuntu" is the one we store the filesystem of Xubuntu. We need to add a new item to point at this partition.    

```
	root@joggler:/boot# cat grub.cfg
	loadfont /unicode.pf2
	terminal_output gfxterm
	set timeout=5
	menuentry "XUbuntu 12.04 LTS (Precise) - 3.2.32joggler1" {
	  linux /vmlinuz-3.2.32joggler1 root=LABEL=Xubuntu ro quiet splash text
	  initrd /initrd.img-3.2.32joggler1
	}

```
#####Change the fstab
We have to change the root partition to "Xubuntu"

```
	root@joggler:/mnt3# cat /mnt3/etc/fstab
	# /etc/fstab: static file system information.
	#
	# Use 'blkid -o value -s UUID' to print the universally unique identifier
	# for a device; this may be used with UUID= as a more robust way to name
	# devices that works even if disks are added and removed. See fstab(5).
	#
	# <file system> <mount point>   <type>  <options>       <dump>  <pass>
	proc             /proc		proc	nodev,noexec,nosuid	0       0
	LABEL=Xubuntu	 /		ext4	errors=remount-ro,noatime		0       1
	LABEL=linux-boot /boot		vfat	defaults		0       0
	LABEL=linux-swap none		swap	sw			0       0

```
Now reboot to see if we could enter xubuntu?  Since we cannot use keyboard in grub, we could only enable one distribution, this is different from the tranditional grub. 
####Configure Bluetooth
Install module for pulseaudio

```
	apt-get install pulseaudio-module-bluetooth

```
Then reboot. Currently connect the bluetooth, then in pulseaudio you will select the corresponding sound card. Enjoy it!    
Tips for avoiding auto hiberate of usb disk, as root:

```
	$ crontab -e
	*/4 * * * * fdisk -l /dev/uba >/dev/null

```
Now your disk will never be hiberate, avoiding system from broken. 
