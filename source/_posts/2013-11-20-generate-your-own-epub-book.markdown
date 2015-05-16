---
layout: post
title: "Generate Your own epub book"
date: 2013-11-20 22:22
comments: true
categories: Linux
---
###Using Wget to fetching the webpages
wget could be used to fetch the webpages from a specified website, using following command could fetch all of the wiki related 1st layer pages from "awesome Wiki"

```
	$ wget -r -l 1 http://awesome.naquadah.org/wiki/Main_Page

```
	
After wget finished, you will found the 1st layer webpatges under your directory. 
###Decide which you want for generating the book
There are some rubbish pages in downloaed pages, thus we have to write a script for fetching the valuable ones, my script is listed as following:

```bash  custom.sh
[Trusty@DashArch wget]$ pwd
/home/Trusty/wget
[Trusty@DashArch wget]$ cd awesome.naquadah.org/
[Trusty@DashArch awesome.naquadah.org]$ ls
doc  download  images  index.html  robots.txt  wiki
[Trusty@DashArch awesome.naquadah.org]$ cd wiki
[Trusty@DashArch wiki]$ cat listitem.sh
#!/bin/sh
for file in `ls `
do
	#echo $file
	type=`file $file | awk {'print $2'}`
	#echo $type
	if [ "$type" = "HTML" ]
	then
		#echo $file
		#echo $type
		echo "<a href=\"$file\">$file</a><br/>"
	fi
done


```
simply run  listitem.sh, we will get the file list tables like following:

```html allfiles.html
<a href="Automounting">Automounting</a><br/>
<a href="Autostart">Autostart</a><br/>
<a href="Autostart_with_consolekit">Autostart_with_consolekit</a><br/>
<a href="Autostop">Autostop</a><br/>
<a href="Awesome_3.0_to_3.1">Awesome_3.0_to_3.1</a><br/>
..........................................

```
Add them into the html like:

```html index.html
<html>
   <body>
     <h1>Table of Contents</h1>
     <p style="text-indent:0pt">
	<a href="Automounting">Automounting</a><br/>
	<a href="Autostart">Autostart</a><br/>
......
	<a href="XRandR_Screen_Table">XRandR_Screen_Table</a><br/>
	<a href="Xscreensaver">Xscreensaver</a><br/>
     </p>
   </body>
</html>

```
###Generate the ebook
Use Calibre, click "Add Book", navigate to your directory which contains "index.html", choose it, and now you can do whatever you want to generate epub, mobi, or 6 inch pdf. Just enjoy your ebook!!!

```
	[Trusty@DashArch Awesome (5)]$ ls -l -h
	total 4.5M
	-rw-r--r-- 1 Trusty root 887K Nov 20 21:07 Awesome - Dash.epub
	-rw-r--r-- 1 Trusty root 511K Nov 20 21:19 Awesome - Dash.mobi
	-rw-r--r-- 1 Trusty root 2.6M Nov 20 21:10 Awesome - Dash.pdf
	-rw-r--r-- 1 Trusty root 560K Nov 20 21:06 Awesome - Dash.zip
	-rw-r--r-- 1 Trusty root 1.1K Nov 20 21:18 metadata.opf

```
Depending on your settings, your generated ebook could be read on NOOK, Kindle, or other mobile equipment. 
