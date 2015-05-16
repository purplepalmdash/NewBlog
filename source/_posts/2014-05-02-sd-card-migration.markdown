---
layout: post
title: "SD Card Migration"
date: 2014-05-02 10:45
comments: true
categories: Linux
---
Following are the tips for operating a SD card under Linux.     
###Backup SD Card
We can use dd for backup sd card into an image file.    

```
dd if=/dev/mmcblk0 of=Your_Image_Name.img bs=1M

```
You need to wait for a moment until all of the data dump working done.    
###Write Into SD Card
Also use dd for writing the image file into the SD card:    

```
dd if=Your_Image_Name.img os=/dev/mmcblk0 bs=1M

```
Make sure your SD Card's volumn is bigger than the image file.     
###Dump SD Card Partition
This is simple, because you can mount the part into some mount points, use following commands:    

```
sudo mount /dev/mmcblock0px /Your_Mount_Point

```
Maybe you have to specify the partition types.    
###Dump Image File Partition
First you have to get the image file partition list via following command:     

```
fdisk BBB_USB.img 

Welcome to fdisk (util-linux 2.24.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk BBB_USB.img: 7.5 GiB, 8035237888 bytes, 15693824 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device       Boot     Start       End  Blocks  Id System
BBB_USB.img1 *         2048    100351   49152   e W95 FAT16 (LBA)
BBB_USB.img2         100352  15693823 7796736  83 Linux

```
From the above output, we know this image file consist of 2 partitions, the first one is a FAT16 partition, the second is the Linux Partition.     
First we use loop device for setting up the partition 1:    

```
# First losetup to delete the mounted equipment
$  losetup -d /dev/loop0
# Now use losetp to set the first partition
# 1048576 = 2048*512, 25165824 = 49152*512. 
$ losetup -v -f -o 1048576 --sizelimit 25165824 ./BBB_USB.img
$ sudo mount /dev/loop1 /mnt
$ cp -ar /mnt/* Your_Directory

```
For the second partition, we use following command:    

```
# sudo mount ./BBB_USB.img -o offset=51380224 /mnt
# cp -ar /mnt/* Your_Directory

```
By doing this you can directly copy out the partition files.    
###Make Filesystem on SD Card
After partition, directly use mkfs.xxx to make filesystems on SD Card. Following is the command which is used for creating vfat fs on SD Card:       

```
mkfs.vfat -F 16/32 -n boot /dev/mmcblk0p1

```
###Zip Image File
You can use following command for zipping the image file, in order to saving the disk space:    

```
bunzip2 z BBB_USB.img

```
or

```
tar cjvf BBB_USB.img.tar.bz2 BBB_USB.img

```
First command will remove the origin image file, while the second one will remain the origin image.    
