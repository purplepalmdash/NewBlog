---
layout: post
title: "在Qemu上运行Raspberry PI镜像"
date: 2013-07-08 18:09
comments: true
categories: Linux Virtualization Embedded
---
1\. 下载和准备镜像文件

```
	$ wget http://downloads.raspberrypi.org/images/raspbian/2013-05-25-wheezy-raspbian/2013-05-25-wheezy-raspbian.zip
	$ unzip 2013-05-25-wheezy-raspbian.zip
```

2\. 查看镜像文件分区信息

```
	$ fdisk -l 2013-05-25-wheezy-raspbian.img 
	Disk 2013-05-25-wheezy-raspbian.img: 1939 MB, 1939865600 bytes, 3788800 sectors
	Units = sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disk label type: dos
	Disk identifier: 0x000c7b31
	
	                         Device Boot      Start         End      Blocks   Id
	System
	2013-05-25-wheezy-raspbian.img1            8192      122879       57344    c 	W95 FAT32 (LBA)
	2013-05-25-wheezy-raspbian.img2          122880     3788799     1832960   83	Linux
```

从上面可以看到，根文件分区的地址偏移为512*122880=62914560

3\. 更改根分区文件里preload信息:

```
	$ sudo mount ./2013-05-25-wheezy-raspbian.img -o offset=62914560 /mnt3
	$ sudo vim /mnt3/etc/ld.so.preload 
	#注释掉这一行，否则在qemu启动完系统后将自动提示配置rpi而造成系统无法登陆
	#/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so
	$ sudo umount /mnt3
```

4\. 用qemu-system-arm启动raspberrypi镜像

```
	$ qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb \
	-no-reboot -serial stdio -append "root=/dev/sda2 panic=1" -hda \
	./2013-05-25-wheezy-raspbian.img 
```

系统将启动到一个root登陆的无需密码的shell中，运行下列命令以修复文件系统:

```
	$ fsck /dev/sda2
	$ shutdown -r now
```

再次启动完毕后的登陆用户名和密码如下，接下来就等同于原机操作了。

```
	Login as pi
	Password raspberry
```

5\. ArchLinux on RaspberryPI

基本步骤也是一样，挂在第2块分区后，需要更改etc/fstab做下列修改：

```
	# <file system>        <dir>         <type>    <options>          <dump> <pass>
	/dev/sda1	  /boot           vfat    defaults        0       0
	/dev/sda2	  /		auto    defaults        0       0
```

之后挂载命令一样。

