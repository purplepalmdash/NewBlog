---
layout: post
title: "AutoRestart autrace"
date: 2014-10-18 11:07
comments: true
categories: Linux
---
autrace is a proxy tool which I used for auto-converting the proxy for cross the firewall, it runs in remote server but sometimes it will runs into crash condition. Following is the command for auto-restart this proxy tool.     

```
$ cat autrace.sh
#!/bin/sh
while true; do
   /home/xxxxxxxx/code/autrace -s 
done

```
Everytime we run autrace.sh like following:    

```
/home/xxxxx/code/autrace.sh &

```
thus autrace will automatically be restart if it crashes.    
