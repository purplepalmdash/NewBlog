---
layout: post
title: "Linux Sound"
date: 2013-12-07 11:05
comments: true
categories: Linux sound
---
###ALSA普通用户无声
只有root才能听到声音，其他一概是哑巴，解决方案：

```
	$ sudo apt-get install acl
	$ sudo setfacl -m u:Your_Username:rw /dev/snd/*

```
等于说赋予了普通用户(Your_Username)访问/dev/snd下所有设备的读写权限。这时候打开mplayer就可以听到MP3播放声了。
###使用tsocks和ssh转发穿越防火墙

```
	ssh -qTfnN -D 1394 xxx@xxx.xxx.xxx.xxx

```
这样可以在本地打开一个socks代理，127.0.0.1:1394
安装tsocks

```
	$ sudo apt-get install tsocks

```
配置tsocks

```
	# vim /etc/tsocks.conf
	# Local networks
	# For this example this machine can directly access 192.168.0.0/255.255.255.0 
	# (192.168.0.*) and 10.0.0.0/255.0.0.0 (10.*)
	
	local = 192.168.0.0/255.255.255.0
	local = 10.0.0.0/255.0.0.0
	server = 127.0.0.1
	server_port = 1394
	server_type = 5

```
试听音乐：

```
	tsocks mplayer http://www.live365.com/play/wkhr

```
但是，用vlc总是提示失败。
###安装archlinux for raspberryPI
下载并解压得到img文件，而后：

```
	[Trusty@XXXyyy arch_rasp]$ fdisk -l archlinux-hf-2013-07-22.img
	
	Disk archlinux-hf-2013-07-22.img: 1.8 GiB, 1960837120 bytes, 3829760 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: dos
	Disk identifier: 0x00057540
	
	Device                       Boot     Start       End  Blocks  Id System
	archlinux-hf-2013-07-22.img1           2048    186367   92160   c W95 FAT32 (LBA)
	archlinux-hf-2013-07-22.img2         186368   3667967 1740800   5 Extended
	archlinux-hf-2013-07-22.img5         188416   3667967 1739776  83 Linux

```
拷贝出根分区：

```
	$ mount ./archlinux-hf-2013-07-22.img -o offset=96468992 /mnt
	$ tar cjvf mnt.tar.bz2 /mnt

```
然后将mnt.tar.bz2解压到某硬盘分区，则可以用该硬盘启动raspberryPI

```
	$ pacman -Syu --noconfirm
	$ pacman -S tigervnc
	$ pacman -S alsa-utils lxde mplayer vlc vim 
   	$ pacman -S xf86-video-fbdev
   	$ pacman -S alsa-utils alsa-firmware alsa-lib alsa-plugins
	$ pacman -S sudo

```
然后我们可以编辑出一个vncserver

```
	$ vncserver
	$ vim /root/.vnc/xstartup
	[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
	xsetroot -solid grey
	xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
	#twm &
	startlxde &
	$ vncserver -kill :1
	$ vncserver

```
添加普通用户的权限和vnc:

```
	$ visudo
	root ALL=(ALL) ALL
	Trusty ALL=(ALL) ALL
	Trusty ALL=(ALL) NOPASSWD: ALL

```
###Start playing on boot
每次允许自动登录：

```
	[Trusty@XXXyyy ~]$ sudo mkdir /etc/systemd/system/getty@tty1.service.d
	[Trusty@XXXyyy ~]$ cat /etc/systemd/system/getty\@tty1.service.d/autologin.conf 
	[Service]
	ExecStart=
	ExecStart=-/usr/bin/agetty --autologin Trusty --noclear %I 38400 linux

```
安装screen

```
	$ pacman -S screen

```
增加自定义服务：

```
	[root@alarmpi ~]# cat /etc/systemd/system/radio.service
	[Unit]
	Description=My Radio
	After=network.target
	
	[Service]
	RemainAfterExit=yes
	ExecStart=/usr/bin/autoradio &
	
	[Install]
	WantedBy=multi-user.target 

```
编写autoradio脚本：

```
	[root@alarmpi ~]# cat /usr/bin/autoradio 
	#!/bin/bash
	screen -d -m sudo -u Trusty cvlc --aout oss http://www.live365.com/play/wkhr --http-proxy=http://10.0.0.221:9001

```
如果想添加管理

```
	[root@alarmpi ~]# cat /usr/bin/autoradio 
	#!/bin/bash
	screen -d -m sudo -u Trusty cvlc --aout oss http://www.live365.com/play/wkhr --http-proxy=http://10.0.0.221:9001 --http-port=5202 --http-password=xxxxxx

```
	

好了，这个Internet Radio就写好了。Enjoy it!!!
	
