---
layout: post
title: "OpenWRT on BBB"
date: 2014-11-01 20:54
comments: true
categories: embedded
---
This article will try to build and run OpenWRT on BBB(BeagleBone Black)    
### Checkout Code
Checkout the code from openwrt.org:     

```
[Trusty@/media/y/embedded/BBB/OpenWRT]$ svn checkout -r 40887 svn://svn.openwrt.org/openwrt/trunk/
......
Checked out revision 40887.

```
Since the wiki said the only workable version for BBB is r40887, we just checkout this specified version.     

```
Currently only runs with openwrt/trunk (r40887) and kernel 3.14.4. Kernel 3.13.7 (as in r40887 on target/linux/omap) will boot the device, but as soon as you attach a USB device, it will freeze.

```

### Patches
Download the patch file from:[http://bpaste.net/show/322887/](http://bpaste.net/show/322887/)    

```
$ wget https://bpaste.net/raw/322887
$ wget https://bpaste.net/raw/322885
$ wget https://bpaste.net/raw/322902
$ mv 322885 Config_Kernel
$ mv 322902 Config_WRT
$ mv 322887 Patch_r40887

```
Notice, the first file should remove the unnecessary lines(patch for the source code).    
Apply the patch:    

```
[Trusty@/media/y/embedded/BBB/OpenWRT_r40887]$ ls
Patch_r40887  Patch_r40887~  trunk
[Trusty@/media/y/embedded/BBB/OpenWRT_r40887]$ cd trunk 
[Trusty@/media/y/embedded/BBB/OpenWRT_r40887/trunk]$ patch -p1 <../Patch_r40887
patching file target/linux/omap/Makefile
patching file target/linux/omap/config-default

```
Now your source file has been patched with the file that you downloaded.    
### Build OpenWRT
In ArchLinux install quilt:    

```
$ sudo pacman -S quilt

```
Then initialize the kernel building via:     

```
$ make target/linux/{clean,prepare} V=99
$ make kernel_oldconfig
$ make kernel_menuconfig # kernel config
$ make menuconfig # OpenWRT  config

```
When make target/linux/{clean, prepare} you should notice configure like this:    
![/images/parametersKernel.jpg](/images/parametersKernel.jpg)    
Then Load the downloaded .config file:    
![/images/saveKernelConfig.jpg](/images/saveKernelConfig.jpg)    
Save to .config file:    
![/images/save2KernelConfig.jpg](/images/save2KernelConfig.jpg)    
Your configuration should be seem like this:    
![/images/yourKernelconfig.jpg](/images/yourKernelconfig.jpg)    

When make the menuconfigs,  load our configured kernel patch file.       
Make:    

```
$ make V=99 -j4

```
During building it will hint for some errors, solution is listed as:    

```
1. Enable the network support during make kernel_menuconfig
2. Configure the git under proxy.     

```
### Flash into SD Card
After building, the result should be available at:    

```
$ pwd
/media/y/embedded/BBB/OpenWRT_r40887/trunk/bin/omap
$ ls
dtbs  md5sums  openwrt-omap-Default-rootfs.tar.gz  openwrt-omap-squashfs.img  openwrt-omap-zImage  packages  uboot-omap-am335x_evm  uboot-omap-omap3_beagle  uboot-omap-omap3_overo  uboot-omap-omap4_panda

```
Now insert a SD card and make the bootable sd card for BBB:    
Since the Card we inserted has a Disklabel type of gpt, like following:    

```
Disk /dev/sdd: 7.4 GiB, 7948206080 bytes, 15523840 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: F2D07CAF-BDA3-426B-AD79-DB2F3F27B3B8

```
So first we want to change it from gpt to dos, just like:    

```
Disklabel type: dos

```
Use gdisk for converting the partition type from "GPT" to "MBR", the command should be r(reovery and transformation options)-> g(convert GPT into MBR and exit) -> w(write the MBR partition table to disk and exit) -> y(Confirum).   
Now the partition should be:    

```
Device     Boot  Start      End  Sectors  Size Id Type
/dev/sdd1         2048   100351    98304   48M  e W95 FAT16 (LBA)
/dev/sdd2       100352 15523839 15423488  7.4G 83 Linux

```
Make filesystems via:    

```
# mkfs.vfat -n boot /dev/sdd1
# mkfs.ext4 /dev/sdd2

```
Copy the existing boot partition (other sd cards) to newly created SD card.    

```
# pwd
/run/media/Trusty/boot
# cp /media/y/embedded/BBB/OpenWRT_r40887/trunk/bin/omap/openwrt-omap-zImage ./zImage

```
In the second partition(/dev/sdd2), unextract the filesystem:    

```
$ cp /media/y/embedded/BBB/OpenWRT_r40887/trunk/bin/omap/openwrt-omap-Default-rootfs.tar.gz  ./
$ tar xzvf openwrt-omap-Default-rootfs.tar.gz 
$ ls
bin  dev  etc  lib  lost+found  mnt  openwrt-omap-Default-rootfs.tar.gz  overlay  proc  rom  root  sbin  sys  tmp  usr  var  www

```
Besure your start-up parameter are like:   

```
# For just using the same mmc part 2
console=ttyO0,115200n8
mmcroot=/dev/mmcblk0p2 ro
mmcrootfstype=ext4 rootwait fixrtc

```
After started the kernel, it will stucked.    


