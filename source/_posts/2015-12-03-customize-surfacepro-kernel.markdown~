---
layout: post
title: "Customize SurfacePro Kernel"
date: 2015-12-03 17:44:32 +0800
comments: true
categories: Kernel
---
### Preparation
Get the kernel and patch file:    

```
To be Written
```

### Build
Prepare for compiliation:    

```
$ make mrproper
```

Get the current running configuration:    

```
$ zcat /proc/config.gz > .config
$ make menuconfig
$ make -j3
$ make modules_install
```

Install Kernel, you newly generated kernel will be named as
`vmlinuz-4.1.13-surfacepro3`(Though surfacepro, surfacepro3 will remains its name) :    

```
$ sudo cp -v arch/x86/boot/bzImage /boot/vmlinuz-4.1.13-surfacepro3
```

Generate the initial RAM disk:    

```
$ sudo mkinitcpio -k 4.1.13-surfacepro3 -c /etc/mkinitcpio.conf -g  \ 
/boot/initramfs-4.1.13-surfacepro3.img
```

Copy System.map, it contains a list of kernel symbols.    

```
$ sudo cp System.map /boot/System.map-4.1.13-surfacepro3
$ sudo ln -sf /boot/System.map-4.1.13-surfacepro3 /boot/System.map
```

Install the grub's configuration into grub.cfg:    

```
$ sudo vim /etc/default/grub
Edit with the name specified
$ sudo grub-mkconfig -o /boot/grub/grub.cfg
```

But still this modification didn't solve surfacepro's wireless problem. finally I have
to fall back to using yaourt's surfac pro kernel.     
