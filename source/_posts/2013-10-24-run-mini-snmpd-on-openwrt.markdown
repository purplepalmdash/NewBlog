---
layout: post
title: "Run mini_snmpd on OpenWRT"
date: 2013-10-24 10:49
comments: true
categories: Linux OpenWRT
---
###OpenWRT Configuration
Install mini_snmpd:

```
	$ opkg update
	$ opkg install mini-snmpd
```

Configure mini_snmpd: mainly changes: option enabled 1, then change the option contact and location. But infact we can only fetch list interfaces in cacti:

```
	root@OpenWrt:~# cat /etc/config/mini_snmpd 
	config mini_snmpd
		option enabled 1
		option ipv6 0
		option community 'public'
		option contact 'gwoguowug@gmail.com'
		option location 'Asia/China/Nanjing'
	
		# enable basic disk usage statistics on specified mountpoint
		list disks '/jffs'
		list disks '/tmp'
	
		# enable basic network statistics on specified interface
		# 4 interfaces maximum, as named in /etc/config/network
		list interfaces 'loopback'
		list interfaces 'lan'
		list interfaces 'wan'
```

Restart the mini_snmpd:

```
	$ /etc/init.d/mini_snmpd restart
```

###Cacti Configuration
Add a new device named OpenWRT, the configuration may like following:  

```
	Change the Host Template to Generic SNMP-enabled Host
	Downed Device Detection - Ping
	Ping Method - ICMP Ping
```

Then you can add your own data sources, graph templates, new graph, new graph Trees, then display them. the picture may looks like as following:

![Alt text](/images/Openwrt_cacti.jpg "OpenWRT cacti")
