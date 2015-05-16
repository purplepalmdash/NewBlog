---
layout: post
title: "EBC Exercises on BBB - Control LED"
date: 2014-11-13 16:09
comments: true
categories: embedded
---
### Using Sysfs
The easiest way to do general purpose I/O(gpio) on BBB is through the terminal and shell command.  sysfs is the virtual file system which exposes the drivers for the hardware so you can directly use them.     

```
# cd /sys/class/leds
# ls
# beaglebone:green:usr0  beaglebone:green:usr1  beaglebone:green:usr2  beaglebone:green:usr3
# cd beaglebone\:green\:usr0
# cat trigger 
none nand-disk mmc0 mmc1 timer oneshot [heartbeat] backlight gpio cpu0 default-on transient 

```
If you want to disable the heartbeat:    

```
# echo none > trigger
# cat trigger 
[none] nand-disk mmc0 mmc1 timer oneshot heartbeat backlight gpio cpu0 default-on transient 

```
Turn on/off the led via:    

```
# echo 1 > brightness
# echo 0 > brightness

```
More trigger options via:   

```
# echo timer>trigger 
# cat trigger 
none nand-disk mmc0 mmc1 [timer] oneshot heartbeat backlight gpio cpu0 default-on transient 

```
Set the deplay frequency:   

```
echo 100>delay_on
echo 900>delay_off

```

### Adding Own LED
Add the connection of LED.     
P9 Pin1 --> 220 ohm  --> LED Negative Pin
P9 Pin 12 -> Led Positive Pin    

Pin 12 in the table is shown in table as GPIO1_28. Bank of 32 each, so find the gpio number via:        
1*32+28=60.     

We have to turn this pin on.     
#### Turn it ON
export/unexport, turn on/off of the LED via following command:    

```
$ cd /sys/class/gpio/
$ echo 60 > export
$ cd gpio60/
$ echo out > direction
$ echo 1 > value
$ echo 0 > value
$ cd ..
$ ls
export  gpio60  gpiochip0  gpiochip32  gpiochip64  gpiochip96  unexport
$ echo 60 > unexport
$ ls -F
export  gpiochip0@  gpiochip32@  gpiochip64@  gpiochip96@  unexport

```
### Add Own Key
Connection for the key:    
P9 Pin 3(3.3V) -->220 ohm --> Key 1    
P9 Pin 42 --> Key 2    
Pin 42 is GPIO0_7, then the actual gpio number is Just 7.     
#### Read Value
export/unexport, read value via following command:    

```
# cd /sys/class/gpio/
# echo 7 > export
# cd gpio7/
# echo in > direction
# cat value
# cat value 
0
Hold down the button and see the result: 
# cat value 
1

``` 
The script for reading the gpio value:    

```
# ./readgpio.sh 7
sh: echo: I/O error
trap: SIGINT: bad trap
__________________________|^^^^^^^^^^^^^^^^^^^^^^^|__________|^^^^^^^^^^|___
___|^^^^^^^|______|^^^^^^^|______|^^^^^^^|______|^^^^^^^|______|^^^^^^^|______|^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|____|^^^^^^^^|____|^^|__|^^|_|^^^^^^|___|^^
|__|^|__|^|__|^|__|^^|___|^|_|^|___|^|_|^|_|^|_|^^|_|^|_|^|_|^^|_|^^^^^^^^^^^^^|______|^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^|____|^^^^^^^^^^^|_____|^^^^^^^^^^^^^^|____|^^^^^^^^^^
^^^|___|^^^^^^^^^^^^|____|^^^^^^^^^^^^|__|^^^^^^^^^^|__|^^^^^^^^|__|^^^^^^^|___|^^^^
^|_____|^^^^^|____|^^^^^^^^^^^^^^^^^^^^^^^|___|^^^^^^^^^^^^^^^^^|___|^^^^^^^^^^^
|_^C

```
This seems like a little game.     

