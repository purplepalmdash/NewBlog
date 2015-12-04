---
layout: post
title: "On Bluetooth PAN"
date: 2015-12-04 10:51:10 +0800
comments: true
categories: Linux
---
### AIM
For sharing the internet connection from working PC to Surface Pro.   

### Setup And Configuration 
#### SurfacePro
Install bluez/bluez-libs/bluez-utils:     

```
$ sudo pacman -S bluez bluez-utils bluez-libs
```

Modprobe the bnep kernel module:    

```
[root@surfacepro ~]# modprobe bnep
[root@surfacepro ~]# lsmod | grep bnep
bnep                   20480  0
bluetooth             450560  6 bnep,btbcm,btrtl,btusb,btintel
[root@surfacepro ~]# modprobe btusb
```

Start the bluetooth.service via:     

```
$ sudo systemctl start bluetooth.service
```

`bluetoothctl` will give access for configurating bluetooth equipment, following steps
shows how to connect to a bluetooth keyboard:     

```
[root@surfacepro ~]# bluetoothctl 
[NEW] Controller xx:xx:xx:xx:xx:xx surfacepro [default]
[bluetooth]#
[bluetooth]# agent KeyboardOnly 
Agent registered
[bluetooth]# default-agent      
Default agent request successful
[bluetooth]# power on
[CHG] Controller xx:xx:xx:xx:xx:xx Class: 0x00011c
Changing power on succeeded
[CHG] Controller xx:XX:XX:XX:XX:XX Powered: yes
[bluetooth]# scan on
Discovery started
[bluetooth]# pair D0:13:1E:11:F5:45
Attempting to pair with D0:13:1E:11:F5:45
[bluetooth]# connect D0:13:1E:11:F5:45
```

Now try to connect to the keyboard, yes you could use keyboard for typing.    

#### PAN
Network Aggregation Point - NAP    


