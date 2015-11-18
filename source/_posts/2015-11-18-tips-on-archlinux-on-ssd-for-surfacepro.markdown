---
layout: post
title: "Tips On ArchLinux On SSD For SurfacePro"
date: 2015-11-18 16:59:00 +0800
comments: true
categories: Linux
---
### Hardware
Surface Pro, KingShare 128G SSD(USB).     

Picture will be updated after successfully installed.    

### Virtualbox Way
Make a vmdk file which actually points to the USB Disk:    

```
$ sudo VBoxManage internalcommands createrawvmdk -filename ./rawusb1.vmdk -rawdisk \ 
/dev/disk/by-id/usb-KINGSHAR_KS-CUTS25W_123456789010-0:0
$ sudo chown -R YourName rawusb1.vmdk
```

Now using this rawdisk for starting the VirtualBox based machine.    

![/images/2015_11_18_17_10_46_645x529.jpg](/images/2015_11_18_17_10_46_645x529.jpg)    

### Installation
The system installation is refers to following links:    

[https://wiki.archlinux.org/index.php/Microsoft_Surface_Pro_3](https://wiki.archlinux.org/index.php/Microsoft_Surface_Pro_3)    

[https://wiki.archlinux.org/index.php/Installing_Arch_Linux_on_a_USB_key](https://wiki.archlinux.org/index.php/Installing_Arch_Linux_on_a_USB_key)   

####    
