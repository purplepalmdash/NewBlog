---
layout: post
title: "Using New DO System"
date: 2015-01-26 23:05
comments: true
categories: linux
---
Since the coreOS met some critical errors, I have to re-construct the DO System using CentOS. So I destroyed the old CoreOS machine, runs CentOS.    
### Configure
### Install packages
Update and install vim

```
$ yum update
$ yum install vim

```

#### Add Swap
512M is not enough for playing, enlarge the swapfile.    

```
# dd if=/dev/zero of=/swapfile bs=1M count=1024
# chmod 600 /swapfile
# mkswap /swapfile
$ sudo vim /etc/systemd/system/swap.service
 [Unit]  
 Description=Turn on swap  
 [Service]  
 Type=oneshot  
 Environment="SWAPFILE=/swapfile"
 RemainAfterExit=true  
 ExecStartPre=/usr/sbin/losetup -f ${SWAPFILE}  
 ExecStart=/usr/bin/sh -c "/sbin/swapon $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"  
 ExecStop=/usr/bin/sh -c "/sbin/swapoff $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"  
 ExecStopPost=/usr/bin/sh -c "/usr/sbin/losetup -d $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"  
 [Install]  
 WantedBy=multi-user.target 
$ sudo  systemctl enable /etc/systemd/system/swap.service  
$ sudo systemctl start swap  

```
Now the swapfile is 1000MB, enough for doing various operations.    
#### Add new user
Add new user and changes its password:    

```
# useradd -m -g root -G root -s /bin/bash Trusty
# passwd Trusty

```
Change the sshd configuration, disable root login, and change the listening port.    

```
vim /etc/ssh/sshd_config
port changes, 
PermitRootLogin no

```
Now reboot the system, you will got a safe DigitalOcean machine.    
### Build OpenContrail
The repo is the same as the above article, then we install other packages which needed for CengOS.    

```
$ sudo yum install -y libtool kernel-devel 
$ sudo yum install -y bzip2 boost-devel tbb-devel libcurl-devel libxml2-devel 

```
Install epel via:    

```
$ sudo yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
$ sudo sed -i -e 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo 

```
Install following packages from epel:    

```
$ sudo yum install -y --disablerepo="*" --enablerepo="epel" scons protobuf protobuf-devel protobuf-compiler 
$  sudo yum install -y python-lxml patch unzip flex bison gcc-c++ openssl-devel make wget python-setuptools

```
So now you could run the whole compilation via `scons` under the ~/Code folder.     
tips: tmux's q will quit ctrl+b mode.    
