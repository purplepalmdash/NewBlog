---
layout: post
title: "Basic ArchLinux Setting(i386)"
date: 2014-03-27 19:10
comments: true
categories: ArchLinux
---
###ArchLinux Installation
First we download the iso from the archlinux.org, then using iso to boot. Partition it into many disks as you like.<br />

Now begin to install:

```
	$ mount /dev/sda2 /mnt
	$ swapon /dev/sda1
	$ pacstrap /mnt base
	$ genfstab -p /mnt >> /mnt/etc/fstab

```
Chroot into the newly installed system:<br />

```
	$ arch-chroot /mnt
	$ ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	$ vi /etc/locale.gen
	# enable en_US related
	$ locale-gen
	$ vi /etc/mkinitcpio.conf
	# we can remain the default, notice if you use usb, enable usb related. 
	$ mkinitcpio -p linux
	$ passwd root

```
Grub install and configure:<br />

```
	$ pacman -S grub
	$ grub-install --target=i386-pc --recheck --debug /dev/sda
	$ grub-install --target=i386-pc --recheck --debug /dev/sda

```
Install vim:<br />

```
	$ pacman -S vim

```
Install dhcpcd:<br />

```
	$ pacman -S dhcpcd
	$ systemctl enable dhcpcd@enp0s3
	$ pacman -S net-tools # for using ifconfig

```
Install openssh:<br />

```
	$ pacman -S openssh
	$ systemctl start sshd
	$ systemcrl enable sshd.service

```

###Build rsim3 on ArchLinux
First download the package from rsim3.<br />
Install the base-devel:<br />

```
	pacman -S base-devel

```
Install boost, boost-libs, libpcap, cppunit:<br />

```
	pacman -S boost boost-libs libpcap cppunit

```
Then you can enjoy the compiling and get the result. 
	
