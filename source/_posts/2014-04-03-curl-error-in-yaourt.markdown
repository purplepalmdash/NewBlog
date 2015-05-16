---
layout: post
title: "CURL Error in Yaourt"
date: 2014-04-03 11:20
comments: true
categories: ArchLinux
---
When downloading package, the yaourt complains:<br />

```
	yaourt curl: (60) SSL certificate problem

```
The solution is via:<br />
Add following lines at the top of the pkg build file:<br />

```
	DLAGENTS=("https::/usr/bin/curl -k -o %o %u")

```
Then restart the yaourt, you can pass through the building. 
