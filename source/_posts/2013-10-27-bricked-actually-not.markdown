---
layout: post
title: "Bricked? Actually not."
date: 2013-10-27 13:05
comments: true
categories: Linux PogoPlug
---
Yesterday I install wicd, a tool for automatically configure the wired and wireless network, but unfortuately it didn't act proper, then made my pogoplug into a brick-like equipment, I can only log into the terminal for less than 15 seconds, then I will lose the ssh connection. How to de-brick this equipment?   
###Solution A
In the 15 seconds living terminal, quickly input following command, this will remove the wicd and use the previous configuration of the network. 

```
	$ yes | apt-get remove wicd &
```

You should wait for a long time, better longer than 5 mins, next time when you reboot into the system, it will recover to previous configuration.
###Solution B
Use serial port.    
In this solution you will need a USB-TTL line to connect to pogoplug's serial port. Use serial port connection will not consider the network configuration. In the serial terminal, simply remove the installed wicd package is OK.
###Solution C
Change the configuration of startup application.    
Navigate yourself to /etc/rc3.d/, you will see several links in this folder, change the S30wicd to K30wicd.   
S mean service, while K means we disable this.    The names of these links all start as either K or S, followed by a number. If the name of the link starts with an S, then that indicates the service will be started when you go into that run level. If the name of the link starts with a K, the service will be killed (if running).   
Reboot and then we will fall back to previous IP address again. 
