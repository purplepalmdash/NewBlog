---
layout: post
title: "Update Linux-ck in ArchLinux"
date: 2013-11-01 16:54
comments: true
categories: Linux Kernel
---
###Add CK kernel repository
Add repository to your /etc/pacman.conf:

```
	[repo-ck]
	Server = http://repo-ck.com/$arch
```

Update the local repository via:

```
	pacman -Syy
	# Check the repo contents:
	pacman -Sl repo-ck
```

###Install the Kernel and related modules
Determine the mach of your cpu'smach CFLAG via;

```
	[root@DashArch ]# gcc -c -Q -march=native --help=target | grep march
	  -march=                     		corei7-avx
```

This indicates the you should install the group ck-sandybridge, according to corei7-avx.     


Install the packages: 

```
	:: There are 7 members in group ck-sandybridge:
	:: Repository repo-ck
	   1) broadcom-wl-ck-sandybridge  2) linux-ck-sandybridge  3) linux-ck-sandybridge-headers  4) nvidia-304xx-ck-sandybridge
	   5) nvidia-ck-sandybridge  6) virtualbox-ck-guest-modules-sandybridge  7) virtualbox-ck-host-modules-sandybridge
	
	Enter a selection (default=all): 2,3,6,7
	resolving dependencies...
	looking for inter-conflicts...
```

Update the grub.cfg:

```
	#linux /boot/vmlinuz-linux root=/dev/sda3
	linux /boot/vmlinuz-linux-ck root=/dev/sda3
	initrd /boot/initramfs-linux-ck.img
```

Now reboot your machine, and you will see your kernel is linux-ck already. 
