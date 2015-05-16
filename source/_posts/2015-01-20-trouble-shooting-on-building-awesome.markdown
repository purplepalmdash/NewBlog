---
layout: post
title: "Trouble-Shooting On Building Awesome"
date: 2015-01-20 21:18
comments: true
categories: Linux
---

When building Awesome following the tutorial of following URL, I met following error:    

```
I installed xcb-proto, but libxcb all the same print "No package 'xcb-proto' found"

```
So the trouble shooting should be done like following, first we found the directory which contains `xcb-proto.pc` via:    

```
$ cd /usr/
$ find . -name "xcb-proto.pc"

```
The result indicates this file locates in the /usr/lib/pkgconfig.    
Easily we add this directory into our `PKG_CONFIG_PATH`, via following commands:    

```
$ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/pkgconfig

```
Now continue to do the configuration, everything will be OK.   
But we got the build error in `make`, like following:    

```
/usr/bin/python ./c_client.py -p /usr/lib/python2.6/site-packages /usr/share/xcb/dri2.xml
Traceback (most recent call last):
  File "./c_client.py", line 1041, in <module>
    module.generate()
  File "/usr/lib/python2.6/site-packages/xcbgen/state.py", line 101, in generate
    item.out(name)
  File "./c_client.py", line 950, in c_request
    _c_accessors(self.reply, name + ('reply',), name)


```   
This may be python version error, change it to python2.7?    
no. We just installed the libxcb-1.8.tar.bz2 for solving this problem.    


libxdg-basedir should be downloaded from following url:    
[http://nevill.ch/libxdg-basedir/downloads/](http://nevill.ch/libxdg-basedir/downloads/)    

So many gaps , we need to do this:    

```
# wget http://nevill.ch/libxdg-basedir/downloads/libxdg-basedir-latest.tar.gz
# tar xzvf libxdg-basedir-latest.tar.gz 
# cd libxdg-basedir-1.2.0/
# ./configure --prefix=/usr
# make && make install
# yum install libpng
# yum install libpng-devel
# ./configure --prefix=/usr && make
# yum install pixman pixman-devel
# wget http://cairographics.org/snapshots/cairo-1.9.12.tar.gz
# tar xzvf cairo-1.9.12.tar.gz 
# cd cairo-1.9.12/
# ./configure --prefix=/usr && make
# make install
# yum install glib2-devel
# yum install gdk-pixbuf2-devel
# yum install startup-notification startup-notification-devel readline readline-devel
# wget http://xcb.freedesktop.org/dist/xcb-util-0.3.8.tar.gz
# tar xzvf xcb-util-0.3.8.tar.gz 
# cd xcb-util-0.3.8/
# ./configure --prefix=/usr
# make && make install
# wget http://xcb.freedesktop.org/dist/xcb-util-cursor-0.1.0.tar.bz2
# tar xjvf xcb-util-cursor-0.1.0.tar.bz2 
# cd xcb-util-cursor-0.1.0/
# ./configure --prefix=/usr && make && make install
# wget http://xcb.freedesktop.org/dist/xcb-util-wm-0.4.0.tar.bz2
# tar xjvf xcb-util-wm-0.4.0.tar.bz2 
# cd xcb-util-wm-0.4.0/
# ./configure --prefix=/usr && make && make install
# firefox https://github.com/csyuschmjuh/cairo-xcb
# cd cairo-xcb-master/
#  ./autogen.sh 
#  ./configure --prefix=/usr && make
#  make install
#  yum install lua-devel

```
Now we could finally build awesome.    
Faint, it failed, so need more investigation.     Later!!!!!!!     
