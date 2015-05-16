---
layout: post
title: "Using pelican for blogging(1)"
date: 2014-01-20 09:52
comments: true
categories: Pelican
---
### Getting Start
Install pelican via pip:
	pip install pelican
Getting started Manual: [http://docs.getpelican.com/en/3.1.1/getting_started.html](http://docs.getpelican.com/en/3.1.1/getting_started.html),  and the command is listed as following:    

```
	# Make sure your pelican is the newest
	$ pip install --upgrade pelican
	$ mkdir ~/code/yoursitename
	$ cd ~/code/yoursitename
	$ pelican-quickstart

```
The "pelican-quickstart" will ask you some questions, after answer all of the questions, you will have a start-up point for the website.      

If your content is OK, run

```
	$ make html && make serve

```
will generate the html files and preview it on the server.    
### Change the Theme
Copy the offical themes into your own directory:

```
	$ git clone --recursive https://github.com/getpelican/pelican-themes ~/pelican-themes

```
Set the default theme in your pelicanconf.py:

``` py pelicanconf.py
	# Use theme for our own 
	# THEME = "/home/Trusty/pelican-themes/mnmlist"
	# THEME = "/home/Trusty/pelican-themes/storm"
	THEME = "/home/Trusty/pelican-themes/html5-dopetrope"

```
Regenerate the site:

```
	$ make html && make serve

```

Notice the pelican is pretty slow for rendering all of the content. For some themes, it may take up to several minutes for generating the whole site! 
	

