---
layout: post
title: "Hacking SteelSeries Engine 3 USB Mouse Under Linux"
date: 2016-02-03 18:36:19 +0000
comments: true
categories: embedded
---
### Background
Since SteelSeries Engine 3 USB mouse have only driver for Windows/MAC, I want to enable
the changing color under Linux, following is the hacking steps.     

### Catching Packets
Using Wireshark for capturing the USB Packages of mouse, at the meantime, use another
mouse for clicking the setting color area, to capture the setting color events, After
this we sent the captured packets to Linux machine for analysing.    

![/images/2016_02_03_18_38_33_587x367.jpg](/images/2016_02_03_18_38_33_587x367.jpg)    

### Setting Color
With the filter and continue for anlysing, found each setting step includes 3 steps.   

Result:    

```
44000000060000005c00000000000000db2a05007169cdb73c0000003c000000
44000000060000005c00000000000000db2a0500036a6db93c0000003c000000
44000000060000005c00000000000000db2a05005b3943ba3c0000003c000000
44000000060000005c00000000000000db2a05002b5930bb3c0000003c000000
44000000060000005c00000000000000db2a05005f51e1bb3c0000003c000000
``` 
Each time's color listed as(R,G,B):    

```
10ad73
2a10ad
ad8e10
ad3c10
ad109b
```

cleaning result:    

```
7169cdb7
036a6db9
5b3943ba
2b5930bb
5f51e1bb
```

Seems no relationship? need to verify the usb protocol mechanism.    
