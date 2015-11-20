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

### Updated Configuration
Finally I installed the surface pro by using a usb dongle which burned the archlinux
installation iso, put it into the surface pro and startup the machine pressing power
key and volume down key, it will goes into the installtion steps.     

Install the system on the SSD, the main steps are available at:    

[http://purplepalmdash.github.io/blog/2014/06/16/archlinux-on-surface-pro/](http://purplepalmdash.github.io/blog/2014/06/16/archlinux-on-surface-pro/)    

```
root@archiso ~ # mount /dev/sdb2 /mnt
root@archiso ~ # mount /dev/sdb1 /mnt/boot/EFI 
root@archiso ~ # arch-chroot /mnt /bin/bash
[root@archiso /]# grub-install --target=x86_64-efi --efi-directory=/boot/EFI \ 
--bootloader-id=arch_grub --recheck
[root@archiso /]# grub-mkconfig -o /boot/grub/grub.cfg
```

Because I frequently change the installtion media(I have SSD and Harddisk), so
everytime I change the installtion media, I have to run above steps again.    

### Kernel Configuration
Install the kernel from yaourt, you could get the surfacepro3 compatiable linux kernel,
install it on surface pro will also be OK:   

```
$ yaourt surfacepro
1 aur/linux-surfacepro3 4.3-1 [installed] (5)
    The Linux-surfacepro3 kernel and modules
2 aur/linux-surfacepro3-docs 4.3-1 (5)
    Kernel hackers manual - HTML documentation that comes with the Linux-surfacepro3
kernel
3 aur/linux-surfacepro3-headers 4.3-1 (5)
    Header files and scripts for building modules for Linux-surfacepro3 kernel
```

After installation, you have to manually generate the grub items:    

```
$ sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Now reboot the surface pro, you could view the kernel has been upgraded to our newly
installed version:    

```
➜  ~  uname -a
Linux surfacepro 4.3.0-1-surfacepro3 #1 SMP PREEMPT Fri Nov 20 05:47:41 CST 2015 x86_64
GNU/Linux
```

With the new version of kernel, you won't face too much problems, my problem is when
using the official kernel, my wifi will get stucked, sometimes the machine will be
dead.    
