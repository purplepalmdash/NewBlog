---
layout: post
title: "Gstreamer Development envionroment Setup on Ubuntu"
date: 2013-10-29 17:22
comments: true
categories: Linux
---
Install the following packages:   

```
	apt-get install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
	apt-get install libgtk2.0-dev
	apt-get install gstreamer0.10-*
	apt-get install gstreamer-plugin*
```

Then add a Makefile in each project:
{% codeblock Makefile -Makefile %}
CFLAGS=`pkg-config --cflags gtk+-2.0 gstreamer-0.10`
LIBS=`pkg-config --libs gtk+-2.0 gstreamer-0.10`
all: tutorial

clean:
	rm *.o tutorial

tutorial.o: tutorial.c tutorial.h
	gcc -g -c tutorial.c $(CFLAGS)

tutorial: tutorial.o
	gcc -o tutorial tutorial.o $(LIBS)
{% endcodeblock %}

	
