---
layout: post
title: "GPT/SSD on ArchLinux Installation"
date: 2015-08-30 09:18:15 +0800
comments: true
categories: Linux
---
Since I met so many problems in archlinux installation on SSD, plus UEFI issues, I use
following virt machine for re-produce the problem and try to find out the solution.    
### Prepare
Prepare two disk, one for SSD, the second is the oridinary one.   

```
$ qemu-img create -f qcow2 -o cluster_size=4k ArchSSD.qcow2 100G
$ qemu-img create -f qcow2 ArchHDD.qcow2 80G
$ virt-manage
```
### UEFI Support In Virt-Manager
Follow the tips in
[https://fedoraproject.org/wiki/Using_UEFI_with_QEMU](https://fedoraproject.org/wiki/Using_UEFI_with_QEMU)    

```
# wget http://www.kraxel.org/repos/firmware.repo -O /etc/yum.repos.d/firmware.repo
# yum install edk2.git-ovmf-x64
# vim /etc/libvirt/qemu.conf
 nvram = [
    "/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd:/usr/share/edk2.git/ovmf-x64/OVMF_VARS-pure-efi.fd",
 ]
```
In customization of the vm, select like following:   

![/images/2015_08_30_10_09_31_306x202.jpg](/images/2015_08_30_10_09_31_306x202.jpg)    

### Virtual Machine Definition
The configuration of the vm machine is listed as in following picture:    

![/images/2015_08_30_09_28_46_445x204.jpg](/images/2015_08_30_09_28_46_445x204.jpg)    

So now begin to install virt-machine. Use iso for booting up the machine and you will
see following partition configuration in the terminal:    

```
root@archiso ~ # fdisk -l /dev/vda
Disk /dev/vda: 100 GiB, 107374182400 bytes, 209715200 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
root@archiso ~ # fdisk -l /dev/vdb
Disk /dev/vdb: 80 GiB, 85899345920 bytes, 167772160 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```   
### Partition Preparation

