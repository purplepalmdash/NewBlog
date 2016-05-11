---
layout: post
title: "Setup LXD On Ubuntu1604"
date: 2016-05-11 15:38:23 +0800
comments: true
categories: Virtualization
---
### Preparation
By default the lxd is installed in ubuntu1604.    
### Image
The image file are downloaded before we actually install it, install the image via:    

```
$ lxc image import ubuntu-16.04-server-cloudimg-amd64-lxd.tar.xz ubuntu-16.04-server-cloudimg-amd64-root.tar.xz --alias ubuntu1604
$ lxc image list
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |             DESCRIPTION              |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu1604   | f4c4c60a6b75 | no     | Ubuntu 16.04 LTS server (20160420.3) | x86_64 | 137.54MB | May 10, 2016 at 2:18pm (UTC) 
```

### Start Container
Start the container via:    

```
$ lxc launch ubuntu1604 first1404
$ lxc list
+------------+---------+------+------+------------+-----------+
|    NAME    |  STATE  | IPV4 | IPV6 |    TYPE    | SNAPSHOTS |
+------------+---------+------+------+------------+-----------+
| first1404  | RUNNING |      |      | PERSISTENT | 0         |
+------------+---------+------+------+------------+-----------+
```
Attach to the running container via:    

```
$ lxc exec first1404 /bin/bash
```
In this container you could do anything, for your customization of the container. 

### More Images
After your modification is done, shutdown the running container, and submit your 
modification to a new container:    

```
$ lxc publish second1604 --alias my-new-image
$ lxc image list
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |             DESCRIPTION              |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| my-new-image | 67de38342bfa | no     |                                      | x86_64 | 192.29MB | May 11, 2016 at 7:07am (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu1604   | f4c4c60a6b75 | no     | Ubuntu 16.04 LTS server (20160420.3) | x86_64 | 137.54MB | May 10, 2016 at 2:18pm (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
```

### Container Networking
The default networking is a seperated network, but we could set the lxd using the hosted
network, via following steps:    

```
$ cat /etc/network/interfaces

auto ens3
iface ens3 inet manual

auto containerbr 
iface containerbr inet static
address 192.168.10.193
netmask 255.255.0.0
gateway 192.168.0.176
dns-nameservers 180.76.76.76
bridge_ports ens3
```
Reboot the machine, you have the running bridge `containerbr`, now you could set your bridge to this 
newly created bridge:    

```
$ lxc profile device set default eth0 parent containerbr
```
Via this you cuold set the same subnet networking address just as in `containerbr`.    
