---
layout: post
title: "OpenWRT on Mercury MW151RM3G"
date: 2013-10-15 19:07
comments: true
categories: Linux
---
1\. Change Mercury MW151RM3G into TP-Link 703N. You have to download the firmware named "MW151rm3G_to_wr703nv1" from google searched result. After flashing this onto your Mercury MW151RM3G, In fact you have got a TP-LINK 703N.   

2\. Download the latest firmware of TP-LINK 703N from openwrt.org. The Download URL is located at [http://wiki.openwrt.org/toh/tp-link/tl-wr703n](http://wiki.openwrt.org/toh/tp-link/tl-wr703n "tl-wr703n"). You can get two files, named "squashfs-factory.bin" and "squashfs-sysupgrade.bin", the factory.bin is for flashing firstly, after flashed this image, flash another named sysupgrade.bin. This will lead your MW151RM3G into a OpenWRT based system.  

3\. Now you have to change the status of your MW151RM3G's ethernet port from static ip address into dhcp based address. Then plug it into the Wireless Router, you will found the OpenWRT's IP address from you router's connected equipments. Log on it, open the openssh server, log into the router.  

4\. Now we can boot the system using flash disk, because the inner image is too small for run applications.  

5\. Prepare the flash disk, format it into ext3 based partition.  

6\. Install the necessary package on OpenWRT:

```
	$ opkg update
	$ opkg install block-mount
	$ opkg install kmod-usb-storage 
	$ opkg install fdisk
	$ opkg install kmod-fs-ext4
```

After the installation, you can mount the flash disk using mount, and your system shall support ext3 based partitions. 

7\. Edit the fstab file, /etc/config/fstab

```
	config mount
	        option target        /overlay
	        option device        /dev/sda1
	        option fstype        ext3
	        option options       rw,sync
	        option enabled       1
	        option enabled_fsck  0
```

Now reboot your MW151RM3G, you will got an 8G based flash disk OpenWRT.
