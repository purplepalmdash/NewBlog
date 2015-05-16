---
layout: post
title: "Updating apache configuration"
date: 2014-03-11 09:45
comments: true
categories: Linux
---
Due to ArchLinux's "pacman -Syu --noconfirm", My apache upgraded from 2.2 to 2.4, thus the configuration file won't work for the new version. When using "systemctl restart httpd.service", it complains some module won't be loaded. <br />

For solving this problem, first make sure you upgraded to the newest version, then go to directory of "/etc/httpd/conf", backup your own httpd.conf, then move the httpd.conf.pacnew into httpd.conf, then restart the httpd.service. <br />

The configuration of the httpd.conf should also be upgraded, notice the following lines in my own configuration file: 

```
	DocumentRoot "/home/Trusty/code/octo/heroku/Tomcat/public"
	#DocumentRoot "/srv/http"
	#<Directory "/srv/http">
	<Directory "/home/Trusty/code/octo/heroku/Tomcat/public">

```

Restart again, and now your apache should work properly again. 
