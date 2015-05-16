---
layout: post
title: "Miragating from ASP to Wordpress(2)"
date: 2014-03-17 16:02
comments: true
categories: WordPress
---
Recent days I am doing a data migration from asp website to WordPress, Following is how-to. <br />
###Database
First we have to download the whole website content from the server, in my situation, the website contains a database called "xxxx.mdb", I downloaded this database and renamed its name to "origin.mdb"<br />
We can use Microsoft Access for opening this database file, and from the left side panel we can see all of the tables. <br />
We know the about/news1/news2/news3/news4 table which contains the actual webpages content. <br />
We can see the picture of news1 which displayed as following: <br />
![/images/tablesInAccess.jpg](/images/tablesInAccess.jpg)
###CSV Preparation
In a Ubuntu machine, we install mdbtools via following command:<br />

```
	$ sudo apt-get install mdbtools

```
Export the specified tables from the mdb file: <br />

```
	$ mdb-export origin.mdb news > news.csv

```
The CSV file is seperated via semicolon, just linke following:<br />

```
	$ cat news.csv
	id,title,entitle,url,body,enbody,zz,hit,data,ssfl,img,ly,enly,color,encolor,tuijian,px_id,pass,kin
	58,"关于海外游学",,,"<DIV><B><FONT size=2 face=Arial>关于游学</FONT></B></DIV>
	<DIV><FONT size=2><FONT face=Arial><STRONG></STRONG><B></B></FONT></FONT>&n
	............

```
Now the news.csv contains all of the content which contains in the news table. <br />
###WordPress Plugins Installation
Install the WP Ultimate CSV Importer for importing the csv into the WordPress:<br />
This Plug-ins is fairly frendly, we simply upload the csv onto the plug-in, the plugin will analyse the csv's content,and begin to mapping the database fields. <br />
![/images/csvimport.jpg](/images/csvimport.jpg)

Notice: You can import the csv into posts or pages, here I choose "Pages", and it got the Parent Pages, so first you have to create the parent page, just as following:<br /> 
![/images/parentpage.jpg](/images/parentpage.jpg)

The content of parent page named "[child_pages]" is also another plug-in, this plug-in is called "Child Pages Shortcode", after installed it, you can get the "screenshots" of the child pages.<br />
The actual effects is listed as following picture: <br />
![/images/childpageshot.jpg](/images/childpageshot.jpg)

Another plug-in is called "Children Index Shortcode". This plug-in will generate all of the child pages' hyper-links. You can call this plug-in via insert "children-index" into the content of the parent page. <br />
###Change The Theme
You can easily install themes in wordpress, via Appearence->Theme. <br />
Currently I use "BlackBird Wordpress Theme", the default suport of chinese is pretty good. <br />
Things to be do:<br />
1. Check all of the images. <br />
2. Beautify the pages. <br />
3. Customize the pages. <br />
