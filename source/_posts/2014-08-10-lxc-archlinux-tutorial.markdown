---
layout: post
title: "LXC ArchLinux Tutorial"
date: 2014-08-10 10:08
comments: true
categories: virtualization
---
### Installation
Install `lxc`, `bridge-utils`, `netctl` from the official repository.     

```
$ sudo pacman -S lxc bridge-utils netctl

```
For creating ArchLinux Container, install arch-install-scripts:    

```
$ sudo pacman -S arch-install-scripts

```
Check Configurations:    

```
$ lxc-checkconfig

```
### Network Configuration
Since I use systemd for bridged network, so this step remains blank, the official Arch Wiki use netctl.    
### Creating Container Using Template
List all of the available templates:   

```
$ ls /usr/share/lxc/templates 
lxc-alpine     lxc-centos    lxc-fedora        lxc-oracle  lxc-ubuntu-cloud
lxc-altlinux   lxc-cirros    lxc-gentoo        lxc-plamo
lxc-archlinux  lxc-debian    lxc-openmandriva  lxc-sshd
lxc-busybox    lxc-download  lxc-opensuse      lxc-ubuntu

```
Now using the template for creating the Linux Container:    

```
$ sudo lxc-create -n Arch_Container -t /usr/share/lxc/templates/lxc-archlinux

```
If the container is created successfully, it will indicates that you could use it from now.    
### Start the Container
List the installed Containers:    

```
$ sudo lxc-ls
Arch_Container  

```
Start the installed Container: 

```
$ sudo lxc-start -n Arch_Container

```
The default username is root, and you will got a terminal window, now check the network configuration:   

```
[root@Arch_Container ~]# ip link show dev eth0
5: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

```
Simply use `dhcpcd` we could get the ip address currently, and surely we can see this network configuration is OK now.    
Enable the automatically dhcpcd at startup    

```
$ dhcpcd
$ systemctl enable dhcpcd.service

```
Now reboot you will notice the ip address has been configurated automatically.    
### Create Other Distributions
First you should install yum and debootstrap from AUR repository.   

```
$ yaourt -S yum
$ yaourt -S debootstrap

```
#### Fedora
Install Fedora or CentOS will failed, I don't know why.    

#### Debian
Install rxync first via: 

```
pacman -S rsync

```
Some packages failed to download, so won't install. 

After installed rsync, install debian container via:    

```
sudo lxc-create -n Debian_Container -t /usr/share/lxc/templates/lxc-debian

```
Start the container via:    

```
 sudo lxc-start -n Debian_Container

```
The default username/password are root, In Debian network is not configured.    
