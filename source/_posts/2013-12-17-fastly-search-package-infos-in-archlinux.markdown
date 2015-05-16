---
layout: post
title: "Fastly search package infos in ArchLinux"
date: 2013-12-17 14:14
comments: true
categories: Linux
---
You can use pkgfile to view the metadata of the pacman files:

```
	pacman -Ss pkgfile
	extra/pkgfile 11-1 [installed]
	    a pacman .files metadata explorer

```
Usage:

```
	pkgfile ls

```
Then you will see "ls" belogns to which package. 

