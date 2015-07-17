---
layout: post
title: "ISCSI Installed Debian Jessie"
date: 2015-07-17 14:24:20 +0800
comments: true
categories: Virtualization
---
### FreeNAS Installation And Configuration
Install Procedure ignored, because it's simple.     
Following steps are used for adding iscsi partition.     

![/images/2015_07_17_14_25_57_558x549.jpg](/images/2015_07_17_14_25_57_558x549.jpg)    
Manually setup the volumn and now you could add your volumn into the FreeNAS System.    

Configure iscsi:    
![/images/2015_07_17_14_33_57_530x370.jpg](/images/2015_07_17_14_33_57_530x370.jpg)   
Add the name of `iqn.onecloud.iscsi`, next we add portal:    
![/images/2015_07_17_14_35_12_617x403.jpg](/images/2015_07_17_14_35_12_617x403.jpg)    
Add Authorized Access Now:    
![/images/2015_07_17_14_37_03_491x195.jpg](/images/2015_07_17_14_37_03_491x195.jpg)    
Add Initator:    
![/images/2015_07_17_14_39_25_498x234.jpg](/images/2015_07_17_14_39_25_498x234.jpg)    
Create target:    
![/images/2015_07_17_14_40_30_460x487.jpg](/images/2015_07_17_14_40_30_460x487.jpg)    
Add extent:   
![/images/2015_07_17_14_41_55_559x613.jpg](/images/2015_07_17_14_41_55_559x613.jpg)   
LUM RPMs could also be spcified:    
![/images/2015_07_17_14_42_51_386x351.jpg](/images/2015_07_17_14_42_51_386x351.jpg)   
Associate Targets:    
![/images/2015_07_17_14_44_09_619x310.jpg](/images/2015_07_17_14_44_09_619x310.jpg)   

Enable the iscsi service:    
![/images/2015_07_17_14_45_04_366x302.jpg](/images/2015_07_17_14_45_04_366x302.jpg)     

Better you change the IP Address into static IP address.     
### Install Debian Jessie Onto ISCSI Disk:    
On a installed Ubuntu, I choose Ubuntu14.04, do following for connecting the exising created iscsi partition:    

```
$ sudo apt-get install -y open-iscsi gdisk
[root:~]# iscsiadm -m discovery -t sendtargets -p 10.47.58.40
10.47.58.40:3260,-1 iqn.onecloud.iscsi:iscsidisk1
``` 
Login and listed the device :   

```
[root:~]# iscsiadm -m node -T 'iqn.onecloud.iscsi:iscsidisk1' -p 10.47.58.40 -l
Logging in to [iface: default, target: iqn.onecloud.iscsi:iscsidisk1, portal: 10.47.58.40,3260] (multiple)
Login to [iface: default, target: iqn.onecloud.iscsi:iscsidisk1, portal: 10.47.58.40,3260] successful.
[root:~]# ls -l /dev/disk/by-path
total 0
lrwxrwxrwx 1 root root 9 Jul 17 05:39 ip-10.47.58.40:3260-iscsi-iqn.onecloud.iscsi:iscsidisk1-lun-0 -> ../../sda
```
Use gdisk for partition the /dev/sda, and creating the filesystem on them:    

```
# gdisk -l /dev/sda

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048            8191   3.0 MiB     EF02  BIOS boot partition
   2            8192         1056767   512.0 MiB   8200  Linux swap
   3         1056768        40959966   19.0 GiB    8300  Linux filesystem
# mkfs.ext4 /dev/sda3
# mkswap /dev/sda2 
```
Now install system, first mount usable systems:    

```
# mkdir /mnt/chroot
# mount /dev/sda3 /mnt/chroot
# debootstrap wheezy /mnt/chroot
# debootstrap jessie /mnt/chroot http://mirrors.aliyun.com/debian/ 

```
chroot into the newly install jessie:    

```
root@Ubuntu-14:~# mount -t proc none /mnt/chroot/proc
root@Ubuntu-14:~# mount -t sysfs none /mnt/chroot/sys
root@Ubuntu-14:~# mount --bind /dev /mnt/chroot/dev
root@Ubuntu-14:~# chroot /mnt/chroot /bin/bash
```

Disk configuration:    

```
root@Ubuntu-14:/# cp /proc/mounts /etc/mtab
root@Ubuntu-14:/# sed -i '\|^/dev/sda3|,$!d' /etc/mtab
root@Ubuntu-14:/# blkid /dev/sda2 /dev/sda3
/dev/sda2: UUID="0c570265-543a-41ec-9edb-65bc55d677cd" TYPE="swap" PARTLABEL="Linux swap" PARTUUID="bfb7c1b1-c6cd-4302-9cb4-d6c1de43a0ad"
/dev/sda3: UUID="c1c5f995-e3f7-48c7-b5d5-4963a77d9b7b" TYPE="ext4" PARTLABEL="Linux filesystem" PARTUUID="00ccaf63-b3b3-46c4-92ab-1933d31cbcb7"
root@Ubuntu-14:/# echo 'UUID=c1c5f995-e3f7-48c7-b5d5-4963a77d9b7b / ext4 errors=remount-ro 0 1' >> /etc/fstab
root@Ubuntu-14:/# echo 'UUID=0c570265-543a-41ec-9edb-65bc55d677cd none swap sw 0 0' >> /etc/fstab
root@Ubuntu-14:/# cat /etc/fstab
# UNCONFIGURED FSTAB FOR BASE SYSTEM
UUID=c1c5f995-e3f7-48c7-b5d5-4963a77d9b7b / ext4 errors=remount-ro 0 1
UUID=0c570265-543a-41ec-9edb-65bc55d677cd none swap sw 0 0
```
Install some packages, be sure to make grub2 installed to /dev/sda:    

```
# apt-get install vim less openssh-server locales
# apt-get install linux-image-amd64 grub2 initramfs-tools
```
Configure the Grub:   

```
# apt-get install open-iscsi
# vim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX=""ISCSI_INITIATOR=iqn.onecloud.iscsi.client:client ISCSI_TARGET_NAME=iqn.onecloud.iscsi:iscsidisk1 ISCSI_TARGET_IP=10.47.58.40 ISCSI_TARGET_PORT=3260 root=UUID=c1c5f995-e3f7-48c7-b5d5-4963a77d9b7b ip=10.47.58.176::10.47.58.1:255.255.255.0:client:eth0:off""
# touch /etc/iscsi/iscsi.initramfs
# echo "InitiatorName=iqn.onecloud.iscsi.client:client" > /etc/iscsi/initiatorname.iscsi
# update-grub
# update-initramfs -u
# passwd

```
Configure the network interfaces:    

```
root@Ubuntu-14:/etc/network# cat interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
#source-directory /etc/network/interfaces.d
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
#iface eth0 inet manual
address 10.47.58.176
netmask 255.255.255.0
gateway 10.47.58.1
dns-nameservers 114.114.114.114
```
Now exit and umount all of the mounted partitions.    

```
# exit
# umount /mnt/chroot/{dev,proc,sys,}
root@Ubuntu-14:~# iscsiadm -m node -T 'iqn.onecloud.iscsi:iscsidisk1' -p 10.47.58.40 -u
# echo "InitiatorName=iqn.onecloud.iscsi.client:client" > /etc/iscsi/initiatorname.iscsi
#!ipxe
set initiator-iqn iqn.2007-08.com.example.client:client
sanboot iscsi:san.example.com:6:3260:0:iqn.2007-08.com.example.san:rootp
```
