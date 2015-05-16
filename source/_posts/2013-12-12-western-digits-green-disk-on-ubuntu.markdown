---
layout: post
title: "Western Digital Green Disk on Ubuntu"
date: 2013-12-12 18:55
comments: true
categories: Linux
---
The WD20EARS (and other sizes include 1.0 and 1.5 TB driver in the series) will attempt to park the read heads once every 8 seconds FOR THE LIFE OF THE HDD which is just horrible! To see if you are affected use the smartctl command (part of smartmontools). If the last column changes rapidly, this section applies to your drive. 

```
	# smartctl /dev/sdb -a | grep Load_Cycle
	193 Load_Cycle_Count        0x0032   001   001   000    Old_age   Always       -       597115	

```
We have to disable this feature. Add lines to /etc/rc.local

```
	hdparam -S 242 /dev/sda
	exit 0

```
The effect for upper comand is listed as: 

```
	# hdparm -S 242 /dev/sda
	/dev/sda:
	 setting standby to 242 (1 hours)

```
By default the disk will standby when 1 hours reached, that will avoid our disk from broken. 
