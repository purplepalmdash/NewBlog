---
layout: post
title: "dhcpd address assignment rules"
date: 2013-11-13 16:30
comments: true
categories: dhcpd
---
1\. Configure the following rules under OpenWRT router:

```
config host
	option name 'beaglebone'
	option ip '10.0.0.123'
```

And in configuration webpage we can see the requiment is like following:

![dhcp.img](/images/dhcpass.jpg)

2\. Now reboot beagle board, to see the client's caught ip address:

```
	root@beaglebone:~# ifconfig
	eth0      Link encap:Ethernet  HWaddr xx:cx:gaoguogueogu  
	          inet addr:10.0.0.123  Bcast:10.0.0.255  Mask:255.255.255.0
	          inet6 addr: fe80::9259:afff:fe65:d98c/64 Scope:Link
	          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
```

Also in OpenWRT router we can see the attached pc:

![assigned](/images/assigned.jpg)

This indicate the client-id specified assignment could judged by dhcpd to assign the specified address
