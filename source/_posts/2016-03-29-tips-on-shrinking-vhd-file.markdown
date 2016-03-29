---
layout: post
title: "Tips On Shrinking VHD File"
date: 2016-03-29 18:15:51 +0800
comments: true
categories: virtualization
---
### UnCleaned Templates Generation
Before remove big files:   

```
[root@fwgwg ~]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00
                       18G  5.1G   12G  31% /
/dev/xvda1             99M   14M   80M  15% /boot
tmpfs                 128M     0  128M   0% /dev/shm
```
Create the vhd file in CloudStack:    

![source/images/2016_03_29_18_17_10_634x380.jpg](source/images/2016_03_29_18_17_10_634x380.jpg)    

Name it:   

![source/images/2016_03_29_18_17_55_301x382.jpg](source/images/2016_03_29_18_17_55_301x382.jpg)    

