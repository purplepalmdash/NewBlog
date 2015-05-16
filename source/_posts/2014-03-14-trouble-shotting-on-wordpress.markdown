---
layout: post
title: "Trouble-Shotting on Wordpress"
date: 2014-03-14 15:52
comments: true
categories: Wordpress
---
Since the Wordpress is located at home, there are several problems for dealing with.<br />
###Changeing Apache Listening Port
Nanjing Unicom has banned the port 80, thus I have to change the default listening port of apache from 80 to other ports. Following is How-To:<br />
First import an variable in /etc/apache2/envvars:<br />

```
	export VHOST_PORT_HTTP=7777

```
Then Change the /etc/apache2/ports.conf: <br />

```
	# NameVirtualHost *:80
	# Listen 80
	NameVirtualHost *:${VHOST_PORT_HTTP}
	Listen ${VHOST_PORT_HTTP}

```
Finally change the site-enabled:<br />

```
	root@arm:/etc/apache2# cat sites-enabled/000-default
	<VirtualHost *:${VHOST_PORT_HTTP}>

```
Now restart the apache2 service, you should see the apache listens the 7777 port. <br />

```
	/etc/init.d/apache2 restart

```

###Configurating the WordPress
Install this light-weight browser for changing configurations. <br />

```
	pacman -S midori

```
After remote login with "ssh -Y", simply input: <br />

```
	midori 

```
Then you can get a local window. <br />
But wait, midori relies on window, but we'd better do everything in command-line for savign the bandwidth, thus we install the elinks, and use it for configurating the wordpress.<br />

```
	$ apt-get install elinks

```
You have to change the configuration->General, from http://xxx.xxx.xxx.xxx to http://xxx.xxx.xxx.xxx:7777, then we can change the port and let it show in browser. <br />

Now you can access the wordpress in everywhere. 
