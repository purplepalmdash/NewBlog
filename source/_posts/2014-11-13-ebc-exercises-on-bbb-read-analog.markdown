---
layout: post
title: "EBC Exercises on BBB - Read Analog"
date: 2014-11-13 18:49
comments: true
categories: embedded
---
### Connection
The wired connection is listed as following:    
Pin 34(analog ground) ---> Negative Pin    
Pin 32(1.8 V) ---> Positive Pin    
Pin 36(AIN5) ---> Wiper     
Pin 32: VADC, Pin 34: AGND, Pin36, AIN5.     
### Operation


```
root@arm:/sys/kernel/debug/pinctrl/44e10800.pinmux# cat /sys/devices/bone_capemgr.*/slots
 0: 54:PF--- 
 1: 55:PF--- 
 2: 56:PF--- 
 3: 57:PF--- 
 4: ff:P-O-L Bone-LT-eMMC-2G,00A0,Texas Instrument,BB-BONE-EMMC-2G
 5: ff:P-O-L Bone-Black-HDMI,00A0,Texas Instrument,BB-BONELT-HDMI
root@arm:/sys/kernel/debug/pinctrl/44e10800.pinmux# SLOTS=/sys/devices/bone_capemgr.*/slots
root@arm:/sys/kernel/debug/pinctrl/44e10800.pinmux# PINS=/sys/kernel/debug/pinctrl/44e10800.pinmux/pins
root@arm:/sys/kernel/debug/pinctrl/44e10800.pinmux# echo cape-bone-iio > $SLOTS
root@arm:/sys/kernel/debug/pinctrl/44e10800.pinmux# cat $SLOTS
 0: 54:PF--- 
 1: 55:PF--- 
 2: 56:PF--- 
 3: 57:PF--- 
 4: ff:P-O-L Bone-LT-eMMC-2G,00A0,Texas Instrument,BB-BONE-EMMC-2G
 5: ff:P-O-L Bone-Black-HDMI,00A0,Texas Instrument,BB-BONELT-HDMI
 7: ff:P-O-L Override Board Name,00A0,Override Manuf,cape-bone-iio
root@arm:/sys/kernel/debug/pinctrl/44e10800.pinmux# find /sys -name "*AIN*"
/sys/devices/ocp.3/helper.15/AIN0
/sys/devices/ocp.3/helper.15/AIN1
/sys/devices/ocp.3/helper.15/AIN2
/sys/devices/ocp.3/helper.15/AIN3
/sys/devices/ocp.3/helper.15/AIN4
/sys/devices/ocp.3/helper.15/AIN5
/sys/devices/ocp.3/helper.15/AIN6
/sys/devices/ocp.3/helper.15/AIN7

```
Now try to read the value out:    

```
# cd /sys/devices/ocp.3/helper.15
# ls
AIN0  AIN1  AIN2  AIN3  AIN4  AIN5  AIN6  AIN7  driver  modalias  power  subsystem  uevent
# cat AIN5
537

```
In the origin material it said should plus 1, to read AIN5 you have to look at AIN6, but it seems wrong, because the table and the interface all starts from 0.    
 
AIN pins are sampled at 12bits and 100k samples per time. while the input voltage is between 0 and 1.8V.       

It's very easy to use anlog read value for controlling some variables, like volumn, brightness, etc.    
