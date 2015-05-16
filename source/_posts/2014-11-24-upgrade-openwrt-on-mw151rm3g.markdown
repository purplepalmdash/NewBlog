---
layout: post
title: "Upgrade OpenWRT on MW151RM3G"
date: 2014-11-24 13:54
comments: true
categories: embedded
---
### Prepare
First go to [http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/generic/](http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/generic/), find the "wr703n", download the 2 files.   

```
$ ls -l openwrt*
-rw-r----- 1 Trusty root 3932160 Nov 24 13:50 openwrt-ar71xx-generic-tl-wr703n-v1-squashfs-factory.bin
-rw-r----- 1 Trusty root 3342340 Nov 24 13:50 openwrt-ar71xx-generic-tl-wr703n-v1-squashfs-sysupgrade.bin

```
sysupgrade.bin is for upgrading.   
### Upgrade
System-> Backup/Flash Firmware.     
Flash New firmware image, choose File. Select the sysupgrade.bin, Upgrade.   

Tehn you have to wait for the changes to be applied, around half a miniutes, then everything will be OK.   
### Use Flash Disk For Booting
Cause the inner storage is only 4M-BYTE, we have to enlarge it via adding the external flash disk .   

```
$ opkg update
$ opkg install block-mount kmod-usb-storage fdisk

```
Comparing to Attitude Adjustment, the kmod-fs-ext4 couldn't be installed, thus we have to formt the flash disk into ext3 format.     

Cause we won't installed the kmod-fs-ext4, so the external system couldn't be used, this time just flash back the Attitude Adjustment.     

### Rootfs on External Storage
Copy the filesystem into the external disk:    

```
root@OpenWrt:/mnt/sda2# tar -C /overlay -cvf - . | tar -C /mnt/sda2 -xf -
root@OpenWrt:/mnt/sda2# ls
etc         lib         lost+found  mnt         sbin        usr

```
Configure the /etc/config/fstab:    

```
config mount
        option target   /overlay
        option device   /dev/sda2
        option fstype   ext3
        option options  rw,sync
        option enabled  1
        option enabled_fsck 0

```
Reboot and you got 8G rootfs enabled router.    
### Wireless-> Wired. 
First set the wireless port to client mode:     
![/images/wireless_client.jpg](/images/wireless_client.jpg)

Then set the wired port to static address:    
![/images/wired_config.jpg](/images/wired_config.jpg)

Now reset  your router and connect the ethernet port with a line, the equipments who only have ethernet could use router's wireless signal for accessing the network.    
Later when I study in the library, this router could easily transfer the signal from wireless to wired and let surfacePro work properly.   
