---
layout: post
title: "Trouble Shooting On Wicd Wireless Connection"
date: 2014-12-04 20:46
comments: true
categories: linux
---
### Problem
Could see the SSID, but could not connect to it.   
### Trouble Shooting
First check the log in `/var/log/wicd`:     

```
[root@TrustyArch wicd]# cat wicd.log
2014/12/04 20:32:02 :: DHCP connection successful
2014/12/04 20:32:02 :: not verifying
2014/12/04 20:32:02 :: Connecting thread exiting.
2014/12/04 20:32:03 :: Sending connection attempt result success
2014/12/04 20:34:20 :: trying to load backend external
2014/12/04 20:34:20 :: trying to load backend ioctl
2014/12/04 20:34:20 :: WARNING: python-iwscan not found, falling back to using iwlist scan.
2014/12/04 20:34:20 :: WARNING: python-wpactrl not found, falling back to using wpa_cli.

```
I think it's because the dhcpcd still alive, so manually kill this process via `pkill dhcpcd`, then re-connect again.    
Trouble Solved. 
