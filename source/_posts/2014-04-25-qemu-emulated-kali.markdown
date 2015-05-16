---
layout: post
title: "Qemu emulated kali"
date: 2014-04-25 10:35
comments: true
categories: kali
---
###Preparation
Create the image file:    

```
$ qemu-img create -f qcow2 kali.qcow2 20G
Formatting 'kali.qcow2', fmt=qcow2 size=21474836480 encryption=off cluster_size=65536 lazy_refcounts=off 
$ ls -l -h
total 136K
-rw-r--r-- 1 Trusty root 193K Apr 25 10:34 kali.qcow2

```

Since I've created the kali, ignore this article.    
