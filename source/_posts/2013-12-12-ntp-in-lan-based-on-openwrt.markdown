---
layout: post
title: "NTP in LAN based on OPENWRT"
date: 2013-12-12 14:13
comments: true
categories: Linux openwrt
---
###Package Installation
Disable the system default ntp server and install ntpd, this ntpd is the real ntpd package, not busybox-ntpd

```
	opkg update
	opkg install ntpd
	/etc/init.d/sysntpd disable
	/etc/init.d/ntpd enable
	/etc/init.d/ntpd start
	netstat -l | grep ntp

```
The client installation, on debian:

```
	apt-get install ntp

```
###Server Configuration
Comment all of the possible reference server, use local time source.

```
	root@OpenWrt:~# cat /etc/ntp.conf 
	# use a random selection of 4 public stratum 2 servers
	# see http://twiki.ntp.org/bin/view/Servers/NTPPoolServers
	
	restrict default nomodify notrap noquery
	#restrict default noquery
	
	#restrict 127.0.0.1
	restrict 10.0.0.0 mask 255.255.255.0 nomodify notrap
	
	server 127.127.1.0	# LOCAL CLOCK
	fudge 127.127.1.0 stratum 0
	
	driftfile  /var/lib/ntp/ntp.drift

```
Then restart the service. Your ntp server is available. 
###Client Configuration
Enable saned to enable ntp client on beaglebone:

```
	# error message
	[....] Starting NTP server: ntpdsaned disabled; edit /etc/default/saned
	vim /etc/default/saned 
	# Set to yes to start saned
	RUN=yes

```
Then we have to enable the ntp client's configuration:     
For Client manually synchornize

```
	root@arm:~# ntpdate 10.0.0.1
	 1 Jan 05:18:55 ntpdate[2243]: the NTP socket is in use, exiting
	root@arm:~# ps -ef | grep ntp
	ntp       1805     1  0 04:30 ?        00:00:00 /usr/sbin/ntpd -p /var/run/ntpd.pid -g -u 107:112
	root      2245  2127  0 05:19 pts/0    00:00:00 grep ntp
	root@arm:~# kill 1805
	root@arm:~# date
	Sat Jan  1 05:19:05 UTC 2000
	root@arm:~# ntpdate 10.0.0.1
	12 Dec 07:38:44 ntpdate[2247]: step time server 10.0.0.1 offset 440129967.397166 sec
	root@arm:~# date
	Thu Dec 12 07:38:46 UTC 2013

```
The client configuration for ntp, remove all of the possible server, use LAN server:

```
	server 10.0.0.1

```
tzselect will set the timezone of the equipment. The result is: 

```
	TZ='Asia/Shanghai'; export TZ

```
Add it into the ~/.profile, then your time will be adjusted to Shanghai Time. 	
###Update time via http
Since I located in UMT+8, I will use following commands for sync the time

```
	date $(wget -O - "http://www.timeapi.org/utc/in+eight+hours" 2>/dev/null | sed s/[-T:+]/\ /g | awk '{print $2,$3,$4,$5,".",$6}' | tr -d " " )

```
Then add it to crontab

```sh time.sh
	root@OpenWrt:~# cat /bin/time.sh 
	#!/bin/sh
	#echo $http_proxy
	#echo $https_proxy
	date $(wget -O - "http://www.timeapi.org/utc/in+eight+hours" 2>/dev/null | sed s/[-T:+]/\ /g | awk '{print $2,$3,$4,$5,".",$6}' | tr -d " " )

```
The crontab -e should like following:

```
	* */3 * * * /bin/time.sh

```
This means every 3 hours the script will be called for synchronizing the time.     
Now we can enjoy the precise time from the internet and make it availale for the service on LAN. 
