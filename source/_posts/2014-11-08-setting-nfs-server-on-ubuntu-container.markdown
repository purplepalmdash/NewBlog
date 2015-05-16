---
layout: post
title: "Setting NFS Server on Ubuntu Container"
date: 2014-11-08 10:17
comments: true
categories: linux
---
Since there are some strange problems in my ArchLinux(Physical Machine), its nfs server will be ignored by the embedded board, while my joggler which runs ubuntu12.04 acts OK. So I try to find a sufficient way for dealing with this issue.    
### Container Configuration
I've installed `Ubuntu_Container` which holds 12.04 in my physical machine. So the nfs server would be configured in this container.    

```
$ sudo apt-get update
$ sudo apt-get install nfs-kernel-server portmap nfs-common

```
Then edit the /srv/nfs4, and export its configuration in /etc/exports:    

```
/srv/nfs4 *(rw,sync,no_root_squash,no_subtree_check)

```
Everytime you want to start the nfs service, just type:    

```
$ /etc/init.d/nfs-kernel-server restart
$ /etc/init.d/portmap restart

```
### Test
Client run:    

```
sudo mount -t nfs 1xx.xx.xx.xx:/srv/nfs4/ /mnt

```
### Trouble-Shooting
The correct parameter for mounting the nfs server is:    

```
setenv bootargs console=ttyO0,115200n8 root=/dev/nfs rw nfsroot=192.168.1.221:/srv/nfs4/BBBrootfs ip=192.168.1.1

```
Then you won't have other problems, even the physical machine could also use the nfs filesystem.    
