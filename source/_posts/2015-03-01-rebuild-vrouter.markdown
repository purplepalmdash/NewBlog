---
layout: post
title: "Rebuild Vrouter"
date: 2015-03-01 22:14
comments: true
categories: Virtualization
---
In order to dive into Vrouter's researching, we build the ko by following comands.    

```
$ cp /opt/contrail/contrail_install_repo/contrail-vrouter-source_1.21-74_all.deb ~/Code/
$ cd ~/Code && ar vx contrail-vrouter-source_1.21-74_all.deb 
$ tar xzvf control.tar.gz 
$ tar xzvf data.tar.gz 
$ cd usr/src/modules/contrail-vrouter/
$ tar xzvf contrail-vrouter-1.21.tar.gz 
$ make

```
After building the ko will be available under the folder
