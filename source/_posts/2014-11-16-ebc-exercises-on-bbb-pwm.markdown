---
layout: post
title: "EBC Exercises on BBB - PWM"
date: 2014-11-16 16:44
comments: true
categories: embedded
---
### PWM
Simply enable the `P9_21` to PWM, then connect to the LED. The LED connection could refer to `EBC Exercises on BBB - Control LED`    

```
SLOTS=/sys/devices/bone_capemgr.*/slots
echo am33xx_pwm > $SLOTS
echo bone_pwm_P9_21 > $SLOTS
cd /sys/devices/ocp.3/pwm_test_P9_21.15/
echo 1000000000 > period
echo  250000000 > duty
echo 1 > run

```
From now you could see the LED begin to flash. In fact using this pwm we could control servo motor:    
[http://www.linux.com/learn/tutorials/776799-servo-control-from-the-beaglebone-black/](http://www.linux.com/learn/tutorials/776799-servo-control-from-the-beaglebone-black/)    

