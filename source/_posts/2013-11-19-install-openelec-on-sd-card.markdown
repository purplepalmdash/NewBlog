---
layout: post
title: "Install OpenELEC on SD Card"
date: 2013-11-19 20:37
comments: true
categories: Linux
---
###Partition the SD card
Insert the SD card and view the partitions via fdisk -l, then

```
	[root@XXXyyy Trusty]# parted -s /dev/mmcblk0 mklabel msdos
	[root@XXXyyy Trusty]# fdisk -l
	Disk /dev/mmcblk0: 7.4 GiB, 7948206080 bytes, 15523840 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: dos
	Disk identifier: 0x0002d03c

```
Make partition 1, fat32, and its size if 16 "cyl" (cylinders)

```
	[root@XXXyyy Trusty]# parted -s /dev/mmcblk0 unit cyl mkpart primary fat32 -- 0 16
	Parameters
	unit unit
	   Set unit as the unit to use when displaying locations and  sizes, unit cyl means cylinders. 
	mkpart part-type [fs-type] start end
	Make  a  part-type  partition  for filesystem fs-type (if
	specified), beginning at start  and  ending  at  end  (by
	default  in megabytes).  part-type should be one of "pri‐
	mary", "logical", or "extended".

```
Make the partition 1 bootable:

```
	$ parted -s /dev/mmcblk0 set 1 boot on
	Device         Boot Start       End Blocks  Id System
	/dev/mmcblk0p1 *     2048    258047 128000   c W95 FAT32 (LBA)

```
Make the second partition:

```
	[root@XXXyyy Trusty]# parted -s /dev/mmcblk0 unit cyl mkpart primary ext2 -- 16 -2
	
	Device         Boot     Start       End  Blocks  Id System
	/dev/mmcblk0p1 *         2048    258047  128000   c W95 FAT32 (LBA)
	/dev/mmcblk0p2         258048  15491071 7616512  83 Linux

```
Now we can see the partitions:

```
	[root@XXXyyy Trusty]# parted -s /dev/mmcblk0 print all
	Model: SD SU08G (sd/mmc)
	Disk /dev/mmcblk0: 7948MB
	Sector size (logical/physical): 512B/512B
	Partition Table: msdos
	Disk Flags: 
	
	Number  Start   End     Size    Type     File system  Flags
	 1      1049kB  132MB   131MB   primary               boot, lba
	 2      132MB   7931MB  7799MB  primary

```
###Make filesystems
Make dos file systems(FAT32) in the first partition:

```
	[root@XXXyyy Trusty]# mkfs.vfat -n System /dev/mmcblk0p1 
	mkfs.fat 3.0.23 (2013-10-15)
	mkfs.fat: warning - lowercase labels might not work properly with DOS or Windows
	-n means the volumn name

```
Make ext4 filesystems in the second partition:

```
	[root@XXXyyy Trusty]# mkfs.ext4 -L Storage /dev/mmcblk0p2
	-L means the Label of the partition

```
###Copy to SD Card
Mount the card

```
	[root@XXXyyy Trusty]# mount /dev/mmcblk0p1  /mnt
	[root@XXXyyy Trusty]# mount /dev/mmcblk0p2  /mnt1

```
Copy 

```
	[root@XXXyyy bcm2835-bootloader-1100e2a]# pwd
	/media/x/code/openELEC/OpenELEC.tv/build.OpenELEC-RPi.arm-devel/bcm2835-bootloader-1100e2a
	[root@XXXyyy bcm2835-bootloader-1100e2a]# cp start.elf  /mnt/
	[root@XXXyyy bcm2835-bootloader-1100e2a]# ls
	bootcode.bin   fixup_cd.dat  fixup_x.dat       start_cd.elf  start_x.elf
	COPYING.linux  fixup.dat     LICENCE.broadcom  start.elf
	[root@XXXyyy bcm2835-bootloader-1100e2a]# sync
	[root@XXXyyy bcm2835-bootloader-1100e2a]# cp bootcode.bin /mnt/
	[root@XXXyyy bcm2835-bootloader-1100e2a]# sync

```
Copy kernel and System

```
	[root@XXXyyy target]# pwd
	/media/x/code/openELEC/OpenELEC.tv/target
	[root@XXXyyy target]# cp OpenELEC-RPi.arm-devel-20131119160254-r16396.kernel  /mnt/kernel.img
	[root@XXXyyy target]# sync
	[root@XXXyyy target]# cp OpenELEC-RPi.arm-devel-20131119160254-r16396.system /mnt/SYSTEM
	[root@XXXyyy target]# sync

```
Make the startup scripts:

```
	[root@XXXyyy mnt]# echo "boot=/dev/mmcblk0p1 disk=/dev/mmcblk0p2 ssh quiet" | tee cmdline.txt
	boot=/dev/mmcblk0p1 disk=/dev/mmcblk0p2 ssh quiet
	[root@XXXyyy mnt]# ls
	bootcode.bin  cmdline.txt  kernel.img  start.elf  SYSTEM
	[root@XXXyyy mnt]# cat cmdline.txt 
	boot=/dev/mmcblk0p1 disk=/dev/mmcblk0p2 ssh quiet

```
###Startup
Now Insert the SD Card into your Raspberry Pi, and enjoy the XBMC. 

