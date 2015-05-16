---
layout: post
title: "Enable Light-Weighted WebServer"
date: 2014-11-18 11:47
comments: true
categories: Linux
---
### TOP Result
Via top we saw:    

```
 2615 mysql     20   0  949.7m 450.7m   0.0  5.7   0:02.62 S mysqld  

```
This caused too much memory be wasted while my blog uses the static pages.   
Solution: I will use a light-weighted web-server.    
### Disable xampp 
Disble and remove the service of xampp via following command:    

```
[root@kkkktt kkk]# systemctl stop xampp.service
[root@kkkktt kkk]# systemctl disable xampp.service
Removed symlink /etc/systemd/system/multi-user.target.wants/xampp.service.

```
### lighttpd
Install via following command and test its configuration:    

```
$ sudo pacman -S lighttpd
[kkk@~]$ ls /etc/lighttpd/lighttpd.conf 
/etc/lighttpd/lighttpd.conf
[kkk@~]$ lighttpd -t -f /etc/lighttpd/lighttpd.conf
Syntax OK

```
Test the webpages:    

```
[kkk@/srv]$ sudo echo 'TestMe!' > /srv/http/index.html
[kkk@/srv]$ chmod 755 /srv/http/index.html
[kkk@/srv]$ sudo systemctl start lighttpd
[kkk@/srv]$ sudo systemctl enable lighttpd
Created symlink from /etc/systemd/system/multi-user.target.wants/lighttpd.service to /usr/lib/systemd/system/lighttpd.service.

```
Use your browser for navigating the http://127.0.0.1, then you could visit this test page.    
### OctoPress Changes
Add following lines into the rakefile:    

```
  system "jekyll"
  # Use rsync for syncing the server directory with the public directory
  system "rsync -vzrtopgu -progress /home/kkk/code/octo/heroku/Tomcat/public/* /srv/http"

```
Then everytime when you type `rake generate`, after generate the static website, the rsync will automatically sync the public folder with remote web server folder `/srv/http`.    

