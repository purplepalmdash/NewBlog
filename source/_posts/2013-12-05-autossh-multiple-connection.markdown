---
layout: post
title: "autossh multiple connection?"
date: 2013-12-05 16:07
comments: true
categories: Linux
---
Strangely, I cannot enable the multiple SSH connections on OpenWRT.    
The configuration file is listed as:
```
	config autossh
		option ssh	'-N -T -R 4381:localhost:22 root@XXX.xxx.xxx.xxx '
		option gatetime	'0'
		option monitorport	'20000'
		option poll	'600'
	#config autossh
	#	option ssh	'-L -N -T 10.0.0.1:9009:1XX.XX.XX.XXX:8000 xxx@xxx.xxx.xxx.xxx '
	#	option gatetime	'0'
	#	option monitorport	'20001'
	#	option poll	'600'
```
But only 1 connection could be enabled.     
I doubt this is because of the startup scripts for /etc/init.d/autossh. I should change its methods.    
```
	start() {
		config_load 'autossh'
		config_foreach start_instance 'autossh'
	}
```
But how to read and display the configuration files? It seems the multiple selections is hard to config.....


