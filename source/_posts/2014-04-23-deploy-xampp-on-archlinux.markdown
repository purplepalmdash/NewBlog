---
layout: post
title: "Deploy XAMPP On ArchLinux"
date: 2014-04-23 14:14
comments: true
categories: Linux
---
###Installation
On ArchLinux, Install xampp via Yaourt:     

```
yaourt xampp

```
After installation, you will find the default xampp located in "/opt/lampp". Start/Stop/Restart the xampp via:

```
/opt/lampp/lampp start/stop/restart

```
###Adjustment
Enable the security via:    

```
/opt/lampp/lampp security

```
Then you have to use username and password for accessing "http://localhost", the default username is lampp, password is what you selected.     
If you want to add your own Directory, add following lines into "/opt/lampp/etc/httpd.conf:     

```
# Add our own Directory
#<Directory "/yourDirectory/">
<Directory "/home/Trusty/code/octo/heroku/Tomcat/public/">
    Options Indexes FollowSymLinks ExecCGI Includes
    AllowOverride All
    Require all granted
</Directory>

```

To enable virtualhost, you have to uncomment following line in "/opt/lampp/etc/httpd.conf:    

```
# Virtual hosts
Include etc/extra/httpd-vhosts.conf

```
Then we should edit the `etc/extra/httpd-xampp.conf`, to change the security issue:     

```
#
# New XAMPP security concept
#
<LocationMatch "^/(?i:(?:xampp|security|licenses|phpmyadmin|webalizer|server-status|server-info))">
	Order deny,allow
	Deny from all
	#Allow from ::1 127.0.0.0/8 \
	#	fc00::/7 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 \
	#	fe80::/10 169.254.0.0/16
	Allow from ::1 127.0.0.0/8
	Allow from all
	ErrorDocument 403 /error/XAMPP_FORBIDDEN.html.var
</LocationMatch>

```

Add more vhosts, the definition is located at /opt/lampp/etc/extra/httpd-vhosts.conf:    

```
<VirtualHost *:80>
DocumentRoot /opt/lampp/htdocs
ServerName localhost
ServerAlias www.localhost
</VirtualHost>


<VirtualHost *:80>
DocumentRoot "/home/Trusty/code/octo/heroku/Tomcat/public/"
ServerName localhost2
ServerAlias www.localhost2
<Directory "/home/Trusty/code/octo/heroku/Tomcat/public/">
Order allow,deny
Allow from all
</Directory>
</VirtualHost>

```
Add the definition of hostname in /etc/hosts:

```
127.0.0.1	localhost2.localdomain	localhost2
127.0.0.1 localhosts # for blog using in XAMPP

```
###Configuration
Add the xampp into the startup procedure, in .xinitrc:    

```
sudo /opt/lampp/lampp start &

```
Then everytime the lampp will automatically start. 

### Add systemd startup
Configure the systemd startup script via following commands:    

```
$ pwd
/etc/systemd/system

$ cat xampp.service
[Unit]
Description=xampp for ArchLinux, locate in /opt/lampp
After=network.target

[Service]
ExecStart=/opt/lampp/lampp start 
ExecStop=/opt/lampp/lampp stop
Type=forking

[Install]
WantedBy=multi-user.target

```	
Enable auto-start xampp.service by default: 

```
# systemctl start xampp.service
# systemctl enable xampp.service
ln -s '/etc/systemd/system/xampp.service' '/etc/systemd/system/multi-user.target.wants/xampp.service'
# ps -ef | grep http

```
