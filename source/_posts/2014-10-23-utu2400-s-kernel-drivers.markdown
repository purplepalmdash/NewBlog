---
layout: post
title: "utu2400's Kernel Drivers"
date: 2014-10-23 10:32
comments: true
categories: embedded
---
### sshd replacement
Since busybox enabled the telnetd by default, we could just use telnet for accessing the board.    

```
[root@www ~]# ps -ef | grep telnet
  861 root       0:00 /usr/sbin/telnetd -l /bin/login
  893 root       0:00 grep telnet

```
### 

