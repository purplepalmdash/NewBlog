---
layout: post
title: "Build nbd Kernel Module On CentOS7"
date: 2015-08-13 17:02:53 +0800
comments: true
categories: Linux
---
### Get Source Code
First check your kernel version via:    

```
$ uname -r
3.10.0-229.7.2.el7.x86_64
```
Then find the corresponding kernel source rpm under vault.centos.org, download its rpm
and install it.     

```
$ wget http://vault.centos.org/7.1.1503/updates/Source/SPackages/kernel-3.10.0-229.7.2.el7.src.rpm
# useradd builder
# groupadd builder
$ rpm -ivh kernel-3.10.0-229.7.2.el7.src.rpm
```

### Build Preparation
As a normal user, do following:    

```
$ mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
$ echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
$ cd ~/rpmbuild/SPECS
$ rpmbuild -bp --target=$(uname -m) kernel.spec
$ cd ~/rpmbuild/BUILD/kernel-3.10.0-229.7.2.el7/linux-3.10.0-229.7.2.el7.centos.x86_64/
$ ls
arch     COPYING  Documentation  fs       ipc      kernel       Makefile  README          scripts   tools
block    CREDITS  drivers        include  Kbuild   lib          mm        REPORTING-BUGS  security  usr
configs  crypto   firmware       init     Kconfig  MAINTAINERS  net       samples         sound     virt
```
Now the source code tree is available.  

### Build
In the kernel source directory, type `make menuconfig` for configurating the kernel
configuration, select :    

Device Driver -> Block devices -> Set "M" On "Network block device support"    

Save the configuration and exit, now begin to make via:    

```
$ make prepare && make modules_prepare && make
``` 
Now makeout the kernel module and copy it to modules directory:    

```
$ make M=drivers/block -j8
$ modinfo drivers/block/nbd.ko
$ sudo cp drivers/block/nbd.ko /lib/modules/3.10.0-229.7.2.el7.x86_64/extra/
$ sudo depmod -a && sudo modprobe nbd
```

Finally met some problems of nbd, don't know why, later will debug on.    

