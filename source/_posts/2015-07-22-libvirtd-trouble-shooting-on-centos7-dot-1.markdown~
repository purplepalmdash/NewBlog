---
layout: post
title: "Libvirtd Trouble-Shooting On CentOS7.1"
date: 2015-07-22 09:54:59 +0800
comments: true
categories: virtualization
---
### Problem Description
When upgraded from CentOS6.6 to CentOS7, the libvirtd will encounter following error:    

![/images/2015_07_22_09_54_37_355x184.jpg](/images/2015_07_22_09_54_37_355x184.jpg)     

Simply remove: 

```
# virsh edit nodename
-     <feature policy='require' name='invtsc'/>
```
