---
layout: post
title: "Establish Ubuntu Virt Node"
date: 2015-03-06 04:50
comments: true
categories: virtualization
---
Just some tips on how to establish an Ubuntu Virt Node from existing installed system.    
### Re-Partition
2T Disk has been allocated to opensuse, thus I have first umount the mounted /home/ partition and use partition from yast for adjust the partition size, I got 1.9 T size of disk for installing new system.    
Umount the mounted /home/ partition is via edit /etc/fstab file.    
### Install Ubuntu
Download the iso file of ubuntu x86_64 version, then enable kvm via:    

```
$ sudo modprobe kvm
$ sudo modprobe kvm-intel

```
Install the system via following commands:     

```
$ qemu-system-x86_64 -hda /dev/sda -m 1024 -boot d -cdrom ./install_media.iso

```
The above command is for installing the system into the real harddisk. It will automatically install the system onto the harddisk and over-write the MBR. Ubuntu will automatically detect the installed opensuse and generate the system description line.    
In grub, the default system will be the installed ubuntu.    
### System Preparation
Install following packages:    

```
$ sudo apt-get install openssh-server vim-gtk bridge-utils virt-manager git subversion sysfsutils virtualbox awesome firefox chromium-browser xinit libreoffice build-essential pidgin konsole meld  fcitx fcitx-googlepinyin git subversion wqy* zsh rox-filer smplayer cmake scrot thunderbird midori gpicview docker.io  qemu qemu-kvm bridge-utils

```
Configure the network via following command:    

```
$ sudo brctl addif br0 eth0
$ cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet manual
# If you want to enable the static, uncomment following
# iface eth0 inet static
#       address 192.168.0.119
#       netmask 255.255.255.0


# Add Bridge Interface
iface br0 inet static
address 192.168.0.119
netmask 255.255.255.0
gateway 192.168.0.236
dns-nameservers 114.114.114.114
bridge_ports eth0
bridge_stp off
auto br0

```
Restart computer and now you got br0 enabled.   

Install QQ:    

```
$ sudo vim /etc/apt/sources.list
deb http://ppa.launchpad.net/lainme/pidgin-lwqq/ubuntu trusty main 
deb-src http://ppa.launchpad.net/lainme/pidgin-lwqq/ubuntu trusty main
$ sudo apt-get update && sudo apt-get upgrade
$ sudo apt-get install pidgin-lwqq

```
Now you could use pidgin for chatting.    

Install xlockmore for using xlock locking screen:    

```
$ wget http://packages.ubuntu.com/precise/amd64/xlockmore/download/*xxxx.deb
$ sudo dpkg -i xlockmore_package.deb

```

Disable UTC time via:    

```
$ sudo vim /etc/default/rcS
# assume that the BIOS clock is set to UTC time (recommended)
UTC=no

```

Configure ZSH:    

```
$ sudo vim ~/.zshrc
# For setting zsh history
HISTFILE=$HOME/.zsh_history
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
HISTSIZE=5000
SAVEHIST=5000

```
Now the history file has been created and you could navigate between command history.    

Quick setup for capturing picture:    

```
$ cat /usr/bin/mycapscr 
scrot -s '%Y_%m_%d_%H_%M_%S_$wx$h.jpg' -e 'mv $f ~/capscr/'
$ mkdir -p ~/capscr

```

Now we got the standard development environment ready. 
