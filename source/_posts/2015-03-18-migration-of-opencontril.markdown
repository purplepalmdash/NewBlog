---
layout: post
title: "Migration of OpenContril"
date: 2015-03-18 11:38
comments: true
categories: Virtualization
---
This article is not for opencontril itself, but for migration of the existing environment to local machines.   
### Environment
Machine configuration is listed as:    

```
192.168.10.233 u12-control
192.168.10.234 u12-compute1
192.168.10.235 u12-compute2

192.168.1.79   s179

```
The control node and 2 compute nodes are running in machine s179, the tasks for me to do is for moving them from s179 to 2 physical machine.    

### Use Remote KVM Server
First we copy our ssh-key to the remote s179 machine, so next time we won't enter any passwd for accessing the remote libvirtd:   

```
$ ssh-copy-id root@192.168.1.79

```
In our own machine, we listed remote's machines via:    

```
$ virsh -c qemu+ssh://root@192.168.1.79/system list --all
 Id    Name                           State
----------------------------------------------------
 14    u14-ui                         running
 16    u14-compute2                   running
 22    u14-compute1                   running
 39    de1-contro                     running
 -     centos6.4-management-01        shut off
 -     centos6.4-management-02        shut off

```
Add connection via: `File-> Add New Connection`, then configure like following:     
![/images/2015_03_18_11_53_11_380x432.jpg](/images/2015_03_18_11_53_11_380x432.jpg)     
### Migration(Static)
First scp the image file to to destination machine, this will take a while.   
Dump the xml via:     

```
$ virsh dumpxml xxxxx>xxxx.xml

```
Scp the xml file to destination machine and move to `/etc/libvirt/qemu/`, change the priviledge of the file:    

```
$ sudo chmod 777 /home/clouder/iso/Ubuntu1404-Newly-Installed-with-Update.img

```     
Edit the corresponding configuration in the xml file:    

```
$ sudo vim /etc/libvirt/qemu/xxxx.xml
.....
<source file='/home/clouder/iso/Ubuntu1404-Newly-Installed-with-Update.img'/>
.....

```
Define the xml under the `/etc/libvirt/qemu/` folder:     

```
root@pc121:/etc/libvirt/qemu# virsh define ./Ubuntu1404-Newly-Installed-with-Update.xml 
Domain Ubuntu1404-Newly-Installed-with-Update defined from ./Ubuntu1404-Newly-Installed-with-Update.xml

```
Install the guest tool and use it for editing the virtual machine:     

```
$ sudo apt-get install libguestfs-tools
$ sudo virt-edit -d Ubuntu1404-Newly-Installed-with-Update /etc/network/interfaces

```
After change the network configuration, we could start the machine via `virsh start Ubuntu1404-Newly-Installed-with-Update`, it will have the newly edited ip address.     


If we use different host machine, then change the following definition in xml file:    

```
$ sudo vim /etc/libvirt/qemu/xxxx.xml
<devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
.......

```

