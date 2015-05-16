---
layout: post
title: "Listening Pandora under linux"
date: 2013-12-09 19:01
comments: true
categories: Linux
---
An script named "piandbar" could let you listen to pandora music in CLI:

```
	$ yaourt -S pianobar

```
Or in ubuntu:

```
	$ apt-get install pianobar

```
The default configuration file could be found under ~/.config/pianobar:

```
	$ cat ~/.config/pianobar/config 
	user = xxx@xxx.com
	password = xxxxxx
	tls_fingerprint =

```
The most cool functionality is it could automatically "remember" all of the played songs.    
man pianobar could get more items, for example key-binding, etc. enjoy the music under CLI. 	
