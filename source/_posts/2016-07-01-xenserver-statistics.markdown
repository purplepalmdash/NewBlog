---
layout: post
title: "XenServer Statistics"
date: 2016-07-01 17:45:50 +0800
comments: true
categories: virtualization
---
Direct write rrd into graphite, refers to:    

```
$ git clone https://github.com/jgilmour/XenGraphiteIT.git
```
Then you get the storage pool information fro xsconsole via:    

```
$ xe vdi-list
```
Notice it will contain the hard disk and iso repositories, use harddisk.    

Now edit the .config file:    

```
[XENAPI]
URL = http://192.168.10.187
USERNAME = root
PASSWORD = xxxxxxx
SR-UUID = 51977c4b-8dc2-bcff-b7ad-de7cc5c7e717

[GRAPHITE]
CARBON_HOST = 192.168.1.79
CARBON_PORT = 2003
CARBON_NAME = collectd.com.IT.servers.xen.
```
Run `python2 xengraphite.py` you could get your XenServer statistic data into your
graphite database, enjoy it.    
