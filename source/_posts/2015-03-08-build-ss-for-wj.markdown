---
layout: post
title: "Build SS for WJ"
date: 2015-03-08 09:17
comments: true
categories: Linux
---
For I have a CentOS host machine on DO, I started to build a SS server which could make use of the freedom network in DO, following is the steps.    
### Python-pip
Python-pip located in epel repository, so first we have to enable epel repository:    

```
# rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
# vim /etc/yum.repos.d/epel.repo
enable=1
# yum -y update

```
Install python-pip via:    

```
# yum install python-pip

```
### SS
Install ShadowSocks via:    

```
# pip install shadowsocks

```
Configure the shadowsocks:    

```
# vim /etc/shadowsocks.json
{
    "server":"1xx.xxx.xxx.xxx",
    "server_port":xxxx,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"Pass!Pass!Pass",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 1
}

```
Use supervisor for managing the ShadowSocks Server:    

```
# yum install -y supervisor
# vim /etc/supervisord.conf
[program:shadowsocks]
command=ssserver -c /etc/shadowsocks.json
autorestart=true
user=nobody

```
Add the supervisord to startup as a daemon:    

```
# vi /etc/rc.d/init.d/supervisord
#!/bin/sh
#
# /etc/rc.d/init.d/supervisord
#
# Supervisor is a client/server system that
# allows its users to monitor and control a
# number of processes on UNIX-like operating
# systems.
#
# chkconfig: - 64 36
# description: Supervisor Server
# processname: supervisord

# Source init functions
. /etc/rc.d/init.d/functions

prog="supervisord"

prefix="/usr/"
exec_prefix="${prefix}"
prog_bin="${exec_prefix}/bin/supervisord"
PIDFILE="/var/run/$prog.pid"

start()
{
       echo -n $"Starting $prog: "
       daemon $prog_bin --pidfile $PIDFILE
       [ -f $PIDFILE ] && success $"$prog startup" || failure $"$prog startup"
       echo
}

stop()
{
       echo -n $"Shutting down $prog: "
       [ -f $PIDFILE ] && killproc $prog || success $"$prog shutdown"
       echo
}

case "$1" in

 start)
   start
 ;;

 stop)
   stop
 ;;

 status)
       status $prog
 ;;

 restart)
   stop
   start
 ;;

 *)
   echo "Usage: $0 {start|stop|restart|status}"
 ;;

esac

```
Now add configuration :     

```
# chmod +x /etc/rc.d/init.d/supervisord
# chkconfig --add supervisord
# chkconfig supervisord on
# chmod a+x  /etc/init.d/supervisord
# service supervisord start

```
Since we updated so much, better we restart the machine and view if ssserver running or not.    

```
$ ps -ef | grep sss
nobody     678   478  0 09:56 ?        00:00:00 /usr/bin/python /usr/bin/ssserver -c /etc/shadowsocks.json
Trusty      1743  1718  0 09:57 pts/0    00:00:00 grep --color=auto sss

```
### Client
Download the Windows client from:    
[http://shadowsocks.org/en/download/clients.html](http://shadowsocks.org/en/download/clients.html)    
Windows 8 above are different from other clients.   

