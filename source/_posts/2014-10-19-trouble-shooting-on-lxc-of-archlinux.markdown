---
layout: post
title: "Trouble-Shooting on LXC of ArchLinux"
date: 2014-10-19 20:37
comments: true
categories: 
---
I try to install ubuntu on ArchLinux using LXC, for the nfs server in ArchLinux seems forbidden the nfsv3's client request, but in my joggler(which runs 12.04 server) the nfs server works OK, so I installed this version for validation.    
### Install method
Install the ubuntu machine via following method:    

```
lxc-create -n Ubuntu_Container -t /usr/share/lxc/templates/lxc-ubuntu

```
### Trouble Shooting
#### qemu-debootstrap
No debootstrap in Archlinux:   

```
which: no qemu-debootstrap in

```
Solution: create a soft link from debootstrap to qemu-debootstrap:    

```
lrwxrwxrwx 1 root root            11 Oct 19 20:13 qemu-debootstrap -> debootstrap

```
#### Keyrings
No keyring file:    

```
I: Keyring file not available at /usr/share/keyrings/ubuntu-archive-keyring.gpg;

```
directly copy one keyring file from installed ubuntu system to local machine.     
#### gpg Checking
gpg1v for checking signature error:    

```
Error executing gpg1v to check Release signature

```
Solution: use --no-check-gpg    
Edit the /usr/share/lxc/templates/lxc-ubuntu file, add --no-check-gpg after all of the debootstrap:    

```
debootstrap --arch=amd64 --verbose --no-check-gpg

```

Now everything should goes OK, and you could enjoy the ubuntu installed on your lxc container.    
