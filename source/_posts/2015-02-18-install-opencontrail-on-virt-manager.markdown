---
layout: post
title: "Install OpenContrail On Virt-Manager"
date: 2015-02-18 10:07
comments: true
categories: virtualization
---
Recently I am studying OpenContrail(based on OpenStack), so following includes the steps for me to setup a single-node emulation environment, the host machine is ArchLinux, which is one of my favorite Linux Distribution, and using nested virtualization for setting up a basic run-time environment.    
### libvirt
It seems the most convinient way for using nested virtualization is for using libvirt, so following is for setting up the virtualization environment.    
First create libvirt user group and add current user into this group:    

```
# groupadd libvirt
# gpasswd -a Trusty libvirt

```
Then uncomment following lines in `/etc/libvirt/libvirtd.conf`:    

```
$ vim /etc/libvirt/libvirtd.conf
unix_sock_group = "libvirt"
unix_sock_ro_perms = "0777"
unix_sock_rw_perms = "0770"
auth_unix_ro = "none"
auth_unix_rw = "none"

```
Then start and enable the libvirtd.service via following commands:    

```
$ sudo systemctl start libvirtd.service
$ sudo systemctl enable libvirtd.service

```
From here you could run `virt-manager` for using virt manager.   
### Installtion of OpenContrail
First you should download the deb file from juniper, then create a 4G Memory, at least 20G disk space virtual machine, notice your cpu selection should enable nested virtualization.    
In Configuration, select "Copy Host CPU Configuration", then your host machine's CPU configuration will be delivered to the virtualized machine.    
The installation steps are:    

```
$ sudo bash
# passwd
# dpkg -i contrail-install-packages_1.21-74~havana_all.deb
# cd /opt/contrail/contrail_packages
# ./setup.sh
# cd /opt/contrail/
# cp utils/fabfile/testbeds/testbed_singlebox_example.py utils/fabfile/testbeds/testbed.py
# cd /opt/contrail/utils
# fab -c fabrc install_contrail
# fab setup_all

```
The installation will automatically restart.   
### OpenStack and OpenContrail
The access webpage are located at:    
OpenStack:    
http://YourIpAddress/horizon    
OpenContrail:    
https://YourIpAddress:8143     
Simply open a browser and view this.    
### Nested
To check the nested virtualization, do following operations:    

```
Trusty@Ubuntu1404:~$ cat /sys/module/kvm_intel/parameters/nested 
Y
Trusty@Ubuntu1404:~$ systool -m kvm_intel -v   | grep -i nested
    nested              = "Y"

```
