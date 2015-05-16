---
layout: post
title: "Tips for deploying ArchLinux on BBB"
date: 2014-10-14 17:33
comments: true
categories: embedded
---
The detailed installation guideline could be found at:    
[http://archlinuxarm.org/platforms/armv7/ti/beaglebone-black](http://archlinuxarm.org/platforms/armv7/ti/beaglebone-black)    

But while there are some tips in changing the uEnv.txt, to enable the boot from 2nd mmc partition. following is the configuration file:     

```
[root@alarm mnt]# cat uEnv.txt
optargs=coherent_pool=1M


#u-boot eMMC specific overrides; Angstrom Distribution (BeagleBone Black) 2013-06-20
kernel_file=zImage
initrd_file=uInitrd
 
loadzimage=load mmc ${mmcdev}:${mmcpart} ${loadaddr} ${kernel_file}
loadinitrd=load mmc ${mmcdev}:${mmcpart} 0x81000000 ${initrd_file}; setenv initrd_size ${filesize}
loadfdt=load mmc ${mmcdev}:${mmcpart} ${fdtaddr} /dtbs/${fdtfile}
#
 
console=ttyO0,115200n8
# If you want to boot from usb
#mmcroot=/dev/sda1 ro
# If you want to boot from SD card
mmcroot=/dev/mmcblk0p2 ro
mmcrootfstype=ext4 rootwait fixrtc


```
Now reboot and then you could see the BBB runs into the ArchLinux.    
