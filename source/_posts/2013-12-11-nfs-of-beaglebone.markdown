---
layout: post
title: "NFS of beaglebone"
date: 2013-12-11 09:32
comments: true
categories: Linux embedded
---
###Serial Preparation
The serial port image is as following:
![serial1.jpg](/images/serial1.jpg)    
     
![serial2.jpg](/images/serial2.jpg)

###Failure information
The bootup failure information is listed as following:

```
	Running uenvcmd ...
	reading zImage
	3345240 bytes read in 383 ms (8.3 MiB/s)
	reading /dtbs/am335x-boneblack.dtb
	24884 bytes read in 10 ms (2.4 MiB/s)
	
	Starting kernel ...
	
	Uncompressing Linux... done, booting the kernel.
	
	Error: unrecognized/unsupported machine ID (r1 = 0x00000e05).
	
	Available machine support:
	
	ID (hex)        NAME
	ffffffff        Generic OMAP4 (Flattened Device Tree)
	ffffffff        Generic AM33XX (Flattened Device Tree)
	ffffffff        Generic OMAP3-GP (Flattened Device Tree)
	ffffffff        Generic OMAP3 (Flattened Device Tree)
	0000060a        OMAP3 Beagle Board
	00000a9d        IGEP OMAP3 module
	00000928        IGEP v2 board
	00000ae7        OMAP4 Panda board
	
	Please check your kernel config and/or bootloader.

```
This is because the configuration file of the uEnv.txt is not right, the right one should be listed as following:

```
	kernel_file=zImage
	initrd_file=uInitrd
	serverip=10.0.0.11
	ipaddr=10.0.0.122
	rootpath=/media/debianroot
	console=ttyO0,115200n8
	
	loadzimage=load mmc ${mmcdev}:${mmcpart} ${loadaddr} ${kernel_file}
	loadinitrd=load mmc ${mmcdev}:${mmcpart} 0x81000000 ${initrd_file}; setenv initrd_size ${filesize}
	loadfdt=load mmc ${mmcdev}:${mmcpart} ${fdtaddr} /dtbs/${fdtfile}
	
	netargs=setenv bootargs console=${console} ${optargs} root=/dev/nfs nfsroot=${serverip}:${rootpath},vers=3 rw ip=${ipaddr}
	#mmcargs=setenv bootargs console=${console} root=${mmcroot} rootfstype=${mmcrootfstype} ${optargs}
	
	#mmc uenvcmd
	#uenvcmd=run loadzimage; run loadfdt; run mmcargs; bootz ${loadaddr} - ${fdtaddr}
	
	#just zImage
	boot_ftd=run loadzimage; run loadfdt
	uenvcmd=run boot_ftd; run netargs; bootz ${loadaddr} - ${fdtaddr}

```
And remember to modify some files: 

```
	root@arm:~# cat /etc/network/interfaces
	# interfaces(5) file used by ifup(8) and ifdown(8)
	auto lo
	iface lo inet loopback
	
	auto eth0
	iface eth0 inet static
	address 10.0.0.122
	netmask 255.255.255.0
	gateway 10.0.0.1

```
Add following lines in /etc/inittab:

```
	T0:23:respawn:/sbin/getty -L ttyO0 115200 vt102

```
Next time when you boot up the beaglebone, it will use the NFS files. 

Tips: when your ownership of su is not right, you will meet"set uid failed" The solution is by Changing the ownership of the su used file;

```
	chmod 4755 /bin/su

```
###NFS Server items
/etc/exports file items:

```
	/media/debianroot 10.0.0.1/24(rw,sync,no_subtree_check,no_root_squash) 10.0.0.11(rw,sync,no_subtree_check,no_root_squash)

```
Restart the nfs server:

```
	/etc/init.d/nfs-kernel-server
	#or
	service nfs-kernel-server restart

```
tar files into your directory:

```
	tar xvfp /media/nfs/beaglebone/debian-7.1-bare-armhf-2013-08-25/armhf-rootfs-debian-wheezy.tar  -C /media/debianroot/

```



