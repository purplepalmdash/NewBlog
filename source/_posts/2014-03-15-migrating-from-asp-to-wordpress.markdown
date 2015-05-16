---
layout: post
title: "Migrating from ASP to WordPress(1)"
date: 2014-03-15 11:00
comments: true
categories: WorldPress
---
Recently I will moving an old-style website from ASP to WorldPress, that's a funny work. This series will record the steps for migrating. <br />
###Preparation
First I got all of the files which locates in the ASP.NET Server, the database is very simple, it's a mdb file, which could be viewed by Microsoft Access.<br />

The static files and images could also be downloaded from the server, thus the materials is enough for building a whole-new WorldPress based website.<br />

###Using Python To Generate Content
All of the webpage information are located in the mdb file, thus we have to do some dealing with this database file. Python could easily retrieve the data out from the database.<br />
Install pyodbc:<br />

```
	$ pip install pyodbc

```
Notice when you are using Microsoft  Access for visiting the database, the system will automatically generate a ldb file for you.<br />

In Linux, the pyodbc will encouter un-predicted problems, so I use ActivePython in Windows for analyzing the mdb file.<br />

```
	$ pypm search pyodbc
	$ pypm install pyodbc

```
Now begin to analyse the database

```
TBD

```
