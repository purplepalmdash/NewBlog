---
layout: post
title: "Turn Joggler into a real Digital Picture Frame"
date: 2014-07-03 14:26
comments: true
categories: joggler
---
In fact Joggler initially is released as a digital picture frame, but I turned it into a linux server. Now It's time to turn this server back.   
### Change RunLevel
Edit the gdm.conf file:     

```
# cat /etc/init/gdm.conf
# gdm - GNOME Display Manager
#
# The display manager service manages the X servers running on the
# system, providing login and auto-login services

description     "GNOME Display Manager"
author          "William Jon McCann <mccann@jhu.edu>"

start on ((filesystem
           and runlevel [!06]
           # Without 03, assume our default level is 03
           #and runlevel [!03]

```
To known your default run level, type:    

```
# runlevel
N 3

```
Then reboot the joggler, to see if you could get the gdm window.   

Disable auto-logon via:    

```
$ cat /etc/init/tty1.conf
respawn
#exec /sbin/mingetty -8 38400 tty1 Trusty -8 38400 tty1
exec /sbin/getty -8 38400 tty1

```

Install lightdm via:    

```
$ sudo apt-get install lightdm
$ sudo dpkg-reconfigure lightdm

```

Enable auto-login to lightdm:    

```
$ cat /etc/lightdm/lightdm.conf 
[SeatDefaults]
autologin-user=Trusty
autologin-user-timeout=0
greeter-session=lightdm-gtk-greeter
user-session=xubuntu

```

### Enable SlideShow
Find out the resolution via following command:    

```
$ xrandr | grep '*'
   800x480        60.0* 

```
Install essential software:   

```
$ sudo apt-get install feh
$ sudo apt-get install unclutter

```
In fact using feh is not good enough for setting the screenSaver, at last I use xscreensaver, it has a mode of glslideshow, you can specify your own directory.    

