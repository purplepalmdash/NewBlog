---
layout: post
title: "Install new image to sd card for BBB"
date: 2014-11-08 16:37
comments: true
categories: embedded
---
Mainly for installing the OpenWRT system on the BBB, following is the steps:    

```
# zImage
cp /media/y/embedded/BBB/svnco/trunk/bin/omap/openwrt-omap-zImage ./zImage
# dtb file
cp /media/y/embedded/BBB/svnco/trunk/bin/omap/dtbs/am335x-boneblack.dtb ./dtbs/


```

