---
layout: post
title: "Install SNMPD in OpenWRT"
date: 2013-10-21 14:36
comments: true
categories: Linux
---
###Install snmpd

```
	$ opkg update && opkg install snmpd
```

The configuration file is /etc/config/snmpd, the configure file could be finetuned. while the file /etc/init.d/snmpd script will make snmpd program to load another cutom config      
snmpd is too big for embedded system, so we use mini-snmpd for openwrt. 
###Install mini-snmpd

```
	$ opkg update && opkg install mini-snmpd
```

The configuration file is located at /etc/config/mini_snmpd, edit this file,for enable the default configration from option enable 0 to option enable 1, this will make mini_snmpd start for default.   
###Use cacti Server Monitor to view the result
In Ubuntu, type: 

```
	$ apt-get install cacti cacti-spine
```

After the installation, you should visiti http://Your_ip_address/cacti for loging, the username and password are "admin" by default, but you will be asked to change it after the first login.   
Go to "Device" click add at the right top, this will ask you to add an equipment for monitoring.   
Fill in the ip address and select the type to "Generic SNMP-enabled Host", then add some additional notes if necessary.   
You can use following command to get the snmpd status:

```
	[Trusty@XXXyyy ~]$ snmpwalk -c public -v 2c 10.0.0.1:161
```


