---
layout: post
title: "Migrate BeagleBone Black"
date: 2014-03-12 19:40
comments: true
categories: BeagleBone
---
Since I want to run wordpress at home, while my RaspberryPI got only 256M RAM, it will be hard to run such a heavy application, I use BeagleBone Black to run it, BeagleBone Black has 512M RAM, which will be enough for run wordpress and etc. <br />

###Setting up NFS Server
First I have to setup a nfs server in my LAN, I set it on my RaspberryPI, since I got only 1 USB hub which serves RaspberryPI, a 500GB harddisk has been attached to the USB hub, which is quite enough for serving nfs servers. <br />
My RaspberryPI runs archlinux, then I follow the ArchLinux's Wiki setting up the nfs server<br />

```
	pacman -S nfs-utils
	# cat /etc/exports
	/media/debianroot 10.0.0.1/24(rw,sync,no_subtree_check,no_root_squash) 10.0.0.11(rw,sync,no_subtree_check,no_root_squash)
	### Check the result
	root@alarmpi ~]# exportfs -arv
	exporting 10.0.0.11:/media/debianroot
	exporting 10.0.0.1/24:/media/debianroot
	exporting 10.0.0.11:/media/debianroot to kernel
	exportfs: 10.0.0.11:/media/debianroot: Function not implemented
	### Change the domainname to "localhost"
	vim /etc/idmapd.conf 
	### Testing the services
	systemctl start rpc-idmapd.service
	systemctl start rpc-mountd.service
	### Enable the Services at startup
	systemctl enable rpc-mountd.service
	systemctl enable rpc-idmapd.service

```
Want testing the nfs, simply use following command: <br />

```
	mount -t nfs 10.0.0.230:/media/debianroot /mnt1

```
If you can see the mnt1 directory has the same content as in nfs server, you can use nfs now. <br />
###Change the BeagleBone Startup file
In SD card, change uEnv.txt

```
	[root@DashArch mnt]# cat uEnv.txt
	kernel_file=zImage
	initrd_file=uInitrd
	serverip=10.0.0.230
	ipaddr=10.0.0.122
	rootpath=/media/debianroot
	console=ttyO0,115200n8

```
###Replace Pogoplug
To replace Pogoplug at home, I have to do the following issues:<br />
1. Use No-ip on BeagleBone, replacing the Pogoplug's No-ip.<br />
2. Run Apache or nginx instead of Pogoplug's service. 

Use No ip: <br />
Install no-ip on RaspberryPI:<br />

```
	pacman -S noip

```
Configure noip on RaspberryPI:<br />

```
	noip2 -C -Y
	[root@alarmpi ~]# systemctl start noip2
	[root@alarmpi ~]# systemctl enable noip2
	ln -s '/usr/lib/systemd/system/noip2.service' '/etc/systemd/system/multi-user.target.wants/noip2.service'
	[root@alarmpi ~]# ps -ef | grep noip
	nobody     411     1  0 00:40 ?        00:00:00 /usr/bin/noip2 -c /etc/no-ip2.conf

```

Now we need to replace Pogoplug's service to RaspberryPI:<br />
First we change the direct port 22 from pogoplug to RasspberryPI on Router. <br />

![/images/redirect.jpg](/images/redirect.jpg)

Now your no-ip pointed machine changed from Pogoplug into RaspberryPI. <br />
###Remote update
Simply replacing the ssh related via setting up the different id_rsa:<br />

```
	cat .ssh/id_rsa.pub | ssh root@xxx.xx.xx.com 'cat >> .ssh/authorized_keys

```
