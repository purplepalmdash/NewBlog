---
layout: post
title: "Build qemu for supporting glustfs"
date: 2015-04-01 16:56
comments: true
categories: 
---
Following is the build procedure.   

```
$ sudo apt-get build-dep qemu
$ sudo apt-get install libvde-dev libvdeplug2-dev libcap-ng-dev libattr1-dev
$ wget http://wiki.qemu-project.org/download/qemu-2.0.2.tar.bz2
$ tar xjvf qemu-2.0.2.tar.bz2
$ cd qemu-2.0.2/
$ mkdir -p bin/debug/native
$ cd bin/debug/native
$ sudo apt-get install libjpeg-turbo8-dev
$ sudo apt-get install glusterfs-common
 ../../../configure --enable-sdl --audio-drv-list=alsa,oss --enable-curses --enable-vnc-jpeg --enable-curl --enable-fdt --enable-kvm --enable-tcg-interpreter --enable-system --enable-user \\n --enable-linux-user --enable-guest-base --enable-pie --enable-uuid --enable-vde --enable-linux-aio --enable-cap-ng --enable-attr --enable-docs --enable-vhost-net --enable-rbd \\n --enable-guest-agent --enable-glusterfs --target-list=x86_64-softmmu,i386-softmmu
 ./qemu-img -h
 $ make -j2

```
Before, Found qemu-img:    

```
$ qemu-img -h
Supported formats: vvfat vpc vmdk vhdx vdi sheepdog sheepdog sheepdog rbd raw host_cdrom host_floppy host_device file qed qcow2 qcow parallels nbd nbd nbd dmg tftp ftps ftp https http cow cloop bochs blkverify blkdebug

```
After, qemu-img:    

```
Supported formats: vvfat vpc vmdk vhdx vdi sheepdog sheepdog sheepdog rbd raw host_cdrom host_floppy host_device file qed qcow2 qcow parallels nbd nbd nbd gluster gluster gluster gluster dmg tftp ftps ftp https http cow cloop bochs blkverify blkdebug

```
