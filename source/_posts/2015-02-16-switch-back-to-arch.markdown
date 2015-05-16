---
layout: post
title: "Switch Back To Arch"
date: 2015-02-16 08:19
comments: true
categories: linux
---
Since I Moved the city and changed the job, my laptop had to be returned to company, so I bought another HP 8460P which is almost the same as my old one. But this one got i7 4 core CPU and more powerful.    
First I installed Ubuntu and start playing virtualization on it, after successfully installed OpenStack and OpenContrail I started to think change back to my archLinux, so following is the steps.     
### grub
Use update-grub2 in Install Ubuntu, it will automatically scan all of the disks, cause I installed the archLinux in the second harddisk, it will add a new item in menu.lst, use this item we could reached ArchLinux.    
### Libvirt
Enable the libvirtd.service via:    

```
sudo systemctl enable libvirtd.service

```
Then restart the system.    
### Nested Virtualization
Manually we could do via:    

```
# modprobe -r kvm_intel
# modprobe kvm_intel nested=1

```
Then check it via:    

```
$ systool -m kvm_intel -v | grep nested
    nested              = "Y"

```
Add it to automatically loaded kernel module:    

```
$ cat /etc/modprobe.d/modprobe.conf
options kvm_intel nested=1

```
Then next time it boots up, will enter the nested mode.    

Didn't solved, fuck!!!!!!!
### Mount LVM Partitions
The steps is listed as following:    

```
[Trusty@~]$ sudo vgscan
  Reading all physical volumes.  This may take a while...
  Found volume group "DashUbuntu-vg" using metadata type lvm2
[Trusty@~]$ sudo vgchange -ay DashUbuntu-vg
  2 logical volume(s) in volume group "DashUbuntu-vg" now active
[Trusty@~]$ sudo lvscan
  ACTIVE            '/dev/DashUbuntu-vg/root' [690.48 GiB] inherit
  ACTIVE            '/dev/DashUbuntu-vg/swap_1' [7.91 GiB] inherit
[Trusty@~]$ sudo mount /dev/DashUbuntu-vg/root /mnt
[Trusty@~]$ ls /mnt
bin   etc         initrd.img.old  lost+found  opt   run   sys  var
boot  home        lib             media       proc  sbin  tmp  vmlinuz
dev   initrd.img  lib64           mnt         root  srv   usr  vmlinuz.old

```
