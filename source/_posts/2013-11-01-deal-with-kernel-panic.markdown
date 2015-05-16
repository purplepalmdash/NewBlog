---
layout: post
title: "Deal With Kernel Panic"
date: 2013-11-01 09:48
comments: true
categories: Linux
---
Recently My ArchLinux always crashes at a certain time after boot up. So following is what I am doing to solve this fucking crash problem. 
###Enable FSCK
I didn't enable fsck at boot up. so now I will open this parameter via:

```
	[root@XXXyyy Trusty]# tune2fs -c 30 /dev/sda2
	tune2fs 1.42.8 (20-Jun-2013)
	Setting maximal mount count to 30
	[root@XXXyyy Trusty]# tune2fs -c 30 /dev/sda3
	tune2fs 1.42.8 (20-Jun-2013)
	Setting maximal mount count to 30
```

###Deal with systemd problem
Check which serivce is failed during startup:

```
	[root@XXXyyy Trusty]# systemctl | grep -i failed
	samba.service                                                                                         loaded failed failed    Samba AD Daemon
	systemd-modules-load.service                                                                          loaded failed failed    Load Kernel Modules
```

Disable the samba.service:

```
	systemctl disable samba.service
```

Check the auto loaded modules:

```
	[root@XXXyyy Trusty]# cat /etc/modules-load.d/virtualbox.conf
	vboxdrv
	#vboxnetflt
	#voxnetadap
	#vboxpci
```

I think the order should have some problems, so I change the sequence to the upper.    
Now  reboot you will get no systemd related problems.
###Video Problems
Install some intel based packages:

```
	pacman -S lib32-intel-dri
	pacman -S libva-intel-driver
```
To Be determined:    
Some issues with X crashing, GPU hanging, or problems with X freezing, can be fixed by disabling the GPU usage with the NoAccel option:

```
	/etc/X11/xorg.conf.d/20-intel.conf
	Section "Device"
	   Identifier "Intel Graphics"
	   Driver "intel"
	   Option "NoAccel" "True"
	EndSection
```

Continue to investigate, next time when my machine is frozened, remote ssh to the machine, to see if it really could be access. 
