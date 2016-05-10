---
layout: post
title: "tips on lxc"
date: 2016-05-10 22:17:35 +0800
comments: true
categories: 
---
### Working Tips
Just for importing the images and let it run in lxc

```
dash@ubuntu:~/may10$ ls
ubuntu-14.04-server-cloudimg-amd64-lxd.tar.xz   ubuntu-15.04-snappy-amd64-generic.img.xz       ubuntu-16.04-server-cloudimg-amd64-root.tar.xz
ubuntu-14.04-server-cloudimg-amd64-root.tar.xz  ubuntu-16.04-server-cloudimg-amd64-lxd.tar.xz
dash@ubuntu:~/may10$ lxc image import ubuntu-14.04-server-cloudimg-amd64-lxd.tar.xz ubuntu-14.04-server-cloudimg-amd64-root.tar.xz --alias ubuntu:14.04
Transferring image: 100%
Image imported with fingerprint: b69c9370446a28c02ad5b0d41f07e028a1756a74bee62b7d59467201a6488fc2
dash@ubuntu:~/may10$ lxc image list
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |            DESCRIPTION             |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
| ubuntu:14.04 | b69c9370446a | no     | Ubuntu 14.04 LTS server (20160406) | x86_64 | 118.89MB | May 10, 2016 at 2:16pm (UTC) |
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
dash@ubuntu:~/may10$ lxc launch ubuntu:14.04 first1404
Creating first1404
error: Get https://cloud-images.ubuntu.com/releases/streams/v1/index.json: lookup cloud-images.ubuntu.com on 180.76.76.76:53: read udp 10.47.58.215:44871->180.76.76.76:53: i/o timeout
dash@ubuntu:~/may10$ lxc launch b69c9370446a first1404
Creating first1404
Starting first1404
dash@ubuntu:~/may10$ lxc image import ubuntu-16.04-server-cloudimg-amd64-lxd.tar.xz ubuntu-16.04-server-cloudimg-amd64-root.tar.xz --alias ubuntu1604
Transferring image: 100%
Transferring image: 100%
Image imported with fingerprint: f4c4c60a6b752a381288ae72a1689a9da00f8e03b732c8d1b8a8fcd1a8890800
dash@ubuntu:~/may10$ lxc image list
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |             DESCRIPTION              |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu1604   | f4c4c60a6b75 | no     | Ubuntu 16.04 LTS server (20160420.3) | x86_64 | 137.54MB | May 10, 2016 at 2:18pm (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu:14.04 | b69c9370446a | no     | Ubuntu 14.04 LTS server (20160406)   | x86_64 | 118.89MB | May 10, 2016 at 2:16pm (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
dash@ubuntu:~/may10$ lxc launch ubuntu1604 first1404
Creating first1404
error: The container already exists
dash@ubuntu:~/may10$ lxc launch ubuntu1604 first1604
Creating first1604
Starting first1604
dash@ubuntu:~/may10$ lxc exec first1604 /bin/bash
root@first1604:~# ls
root@first1604:~# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:16:3e:b0:f2:c3  
          inet addr:10.226.147.79  Bcast:10.226.147.255  Mask:255.255.255.0
          inet6 addr: fe80::216:3eff:feb0:f2c3/64 Scope:Link
dash@ubuntu:~/may10$ ls
ubuntu-14.04-server-cloudimg-amd64-lxd.tar.xz   ubuntu-15.04-snappy-amd64-generic.img.xz       ubuntu-16.04-server-cloudimg-amd64-root.tar.xz
ubuntu-14.04-server-cloudimg-amd64-root.tar.xz  ubuntu-16.04-server-cloudimg-amd64-lxd.tar.xz
dash@ubuntu:~/may10$ lxc image import ubuntu-14.04-server-cloudimg-amd64-lxd.tar.xz ubuntu-14.04-server-cloudimg-amd64-root.tar.xz --alias ubuntu:14.04
Transferring image: 100%
Image imported with fingerprint: b69c9370446a28c02ad5b0d41f07e028a1756a74bee62b7d59467201a6488fc2
dash@ubuntu:~/may10$ lxc image list
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |            DESCRIPTION             |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
| ubuntu:14.04 | b69c9370446a | no     | Ubuntu 14.04 LTS server (20160406) | x86_64 | 118.89MB | May 10, 2016 at 2:16pm (UTC) |
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
dash@ubuntu:~/may10$ lxc launch ubuntu:14.04 first1404
Creating first1404
error: Get https://cloud-images.ubuntu.com/releases/streams/v1/index.json: lookup cloud-images.ubuntu.com on 180.76.76.76:53: read udp 10.47.58.215:44871->180.76.76.76:53: i/o timeout
dash@ubuntu:~/may10$ lxc launch b69c9370446a first1404
Creating first1404
Starting first1404
dash@ubuntu:~/may10$ lxc image import ubuntu-16.04-server-cloudimg-amd64-lxd.tar.xz ubuntu-16.04-server-cloudimg-amd64-root.tar.xz --alias ubuntu1604
Transferring image: 100%
Transferring image: 100%
Image imported with fingerprint: f4c4c60a6b752a381288ae72a1689a9da00f8e03b732c8d1b8a8fcd1a8890800
dash@ubuntu:~/may10$ lxc image list
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |             DESCRIPTION              |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu1604   | f4c4c60a6b75 | no     | Ubuntu 16.04 LTS server (20160420.3) | x86_64 | 137.54MB | May 10, 2016 at 2:18pm (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu:14.04 | b69c9370446a | no     | Ubuntu 14.04 LTS server (20160406)   | x86_64 | 118.89MB | May 10, 2016 at 2:16pm (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
dash@ubuntu:~/may10$ lxc launch ubuntu1604 first1404
Creating first1404
error: The container already exists
dash@ubuntu:~/may10$ lxc launch ubuntu1604 first1604
Creating first1604
Starting first1604
dash@ubuntu:~/may10$ lxc exec first1604 /bin/bash
root@first1604:~# ls
root@first1604:~# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:16:3e:b0:f2:c3  
          inet addr:10.226.147.79  Bcast:10.226.147.255  Mask:255.255.255.0
          inet6 addr: fe80::216:3eff:feb0:f2c3/64 Scope:Link
dash@ubuntu:~/may10$ ls
ubuntu-14.04-server-cloudimg-amd64-lxd.tar.xz   ubuntu-15.04-snappy-amd64-generic.img.xz       ubuntu-16.04-server-cloudimg-amd64-root.tar.xz
ubuntu-14.04-server-cloudimg-amd64-root.tar.xz  ubuntu-16.04-server-cloudimg-amd64-lxd.tar.xz
dash@ubuntu:~/may10$ lxc image import ubuntu-14.04-server-cloudimg-amd64-lxd.tar.xz ubuntu-14.04-server-cloudimg-amd64-root.tar.xz --alias ubuntu:14.04
Transferring image: 100%
Image imported with fingerprint: b69c9370446a28c02ad5b0d41f07e028a1756a74bee62b7d59467201a6488fc2
dash@ubuntu:~/may10$ lxc image list
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |            DESCRIPTION             |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
| ubuntu:14.04 | b69c9370446a | no     | Ubuntu 14.04 LTS server (20160406) | x86_64 | 118.89MB | May 10, 2016 at 2:16pm (UTC) |
+--------------+--------------+--------+------------------------------------+--------+----------+------------------------------+
dash@ubuntu:~/may10$ lxc launch ubuntu:14.04 first1404
Creating first1404
error: Get https://cloud-images.ubuntu.com/releases/streams/v1/index.json: lookup cloud-images.ubuntu.com on 180.76.76.76:53: read udp 10.47.58.215:44871->180.76.76.76:53: i/o timeout
dash@ubuntu:~/may10$ lxc launch b69c9370446a first1404
Creating first1404
Starting first1404
dash@ubuntu:~/may10$ lxc image import ubuntu-16.04-server-cloudimg-amd64-lxd.tar.xz ubuntu-16.04-server-cloudimg-amd64-root.tar.xz --alias ubuntu1604
Transferring image: 100%
Transferring image: 100%
Image imported with fingerprint: f4c4c60a6b752a381288ae72a1689a9da00f8e03b732c8d1b8a8fcd1a8890800
dash@ubuntu:~/may10$ lxc image list
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
|    ALIAS     | FINGERPRINT  | PUBLIC |             DESCRIPTION              |  ARCH  |   SIZE   |         UPLOAD DATE          |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu1604   | f4c4c60a6b75 | no     | Ubuntu 16.04 LTS server (20160420.3) | x86_64 | 137.54MB | May 10, 2016 at 2:18pm (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
| ubuntu:14.04 | b69c9370446a | no     | Ubuntu 14.04 LTS server (20160406)   | x86_64 | 118.89MB | May 10, 2016 at 2:16pm (UTC) |
+--------------+--------------+--------+--------------------------------------+--------+----------+------------------------------+
dash@ubuntu:~/may10$ lxc launch ubuntu1604 first1404
Creating first1404
error: The container already exists
dash@ubuntu:~/may10$ lxc launch ubuntu1604 first1604
Creating first1604
Starting first1604
dash@ubuntu:~/may10$ lxc exec first1604 /bin/bash
root@first1604:~# ls
root@first1604:~# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:16:3e:b0:f2:c3  
          inet addr:10.226.147.79  Bcast:10.226.147.255  Mask:255.255.255.0
          inet6 addr: fe80::216:3eff:feb0:f2c3/64 Scope:Link
....
```
