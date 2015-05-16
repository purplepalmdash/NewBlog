---
layout: post
title: "snmp on Raspberry PI"
date: 2013-10-21 19:19
comments: true
categories: Linux
---
I want to use snmp for administrating my raspberry PI, for example, its disk usage, cpu usage, and etc. following is the how-to of setting up the monitoring environment.    
###Preparation

```
	$ apt-get upate && apt-get upgrade
	$ apt-get install apache2 php5 mysql-client mysql-server
You will be prompted to set a password for mysql root user.
	$ apt-get install php5-mysql php5-snmp rrdtool snmp snmpd
```

