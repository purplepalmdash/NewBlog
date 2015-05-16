---
layout: post
title: "Build Pidgin And WebQQ"
date: 2015-02-06 20:35
comments: true
categories: linux
---
Strangely my OpenSuse's official installation version's pidgin doesn't support webqq plugins. So I have to build from source and let it run as a webQQ's version of pidgin.     
### Getting Source.   
First download the source code from:    
[http://sourceforge.net/projects/pidgin/files/Pidgin/2.10.11/pidgin-2.10.11.tar.bz2/download?accel_key=62%3A1423272982%3Ahttp%253A//www.pidgin.im/download/source/%3A20b420a2%24f93cd8a6095e965a3448df4a97a1c4786bf0a085&click_id=b8d33c98-ae69-11e4-8d6d-0200ac1d1d8d&source=accel](http://sourceforge.net/projects/pidgin/files/Pidgin/2.10.11/pidgin-2.10.11.tar.bz2/download?accel_key=62%3A1423272982%3Ahttp%253A//www.pidgin.im/download/source/%3A20b420a2%24f93cd8a6095e965a3448df4a97a1c4786bf0a085&click_id=b8d33c98-ae69-11e4-8d6d-0200ac1d1d8d&source=accel)    
Install related packages:   

```
$ sudo zypper in intltool
$ sudo zypper in gtk3-devel
$ sudo zypper in gtk2-devel
$ sudo zypper in gstreamer-devel
$ sudo zypper in libidn-devel
$ sudo zypper in meanwhile-devel
$ sudo zypepr in libavahi-devel
$ sudo zypper in libavahi-glib-devel
$ sudo zypper in libgnutls-openssl-devel
$ sudo zypper in tcl-devel 
$ sudo zypper in tk-devel 
$ sudo zypper in gtkspell-devel


```
Configure pidign via:   

```
./configure --prefix=/home/Trusty/bin --disable-screensaver  --disable-gstreamer --disable-vv

```
Notice here I disable the screensave support and gstreamer support.  
### Make
Via `make` and `make install` we could let it run.   
Make install the corresponding plugins, and now your webqq is OK.    
