---
layout: post
title: "HMC5883L on RaspberryPI"
date: 2013-11-16 20:15
comments: true
categories: Raspberry Pi Linux
---
###Make sure you have installed i2c tools
Install i2c-tools via:

```
	# apt-get install i2c-tools
	# apt-cache search i2c-tools
	i2c-tools - heterogeneous set of I2C tools for Linux
```

Check if spi and i2c has been blacklisted in system:

```
	# cat  /etc/modprobe.d/raspi-blacklist.conf 
	# blacklist spi and i2c by default (many users don't need them)
	
	blacklist spi-bcm2708
	blacklist i2c-bcm2708

```
Comment out them, now your i2c will not be blacklisted.    
Add following items into /etc/modules:

```
	i2c-bcm2708
	i2c-dev

```
Enable the user to access i2c equipments in user space: 

```
	root@rasp:~# cat /etc/udev/rules.d/99-i2c.rules 
	SUBSYSTEM==”i2c-dev”, MODE=”0666″

```
Reboot and check the result.     

```
	root@rasp:~# ls /dev/i2c*
	/dev/i2c-0  /dev/i2c-1

```
Now your i2c equipments become available. Detect the attached equipments:

```
	root@rasp:~# i2cdetect -y 0
	     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
	00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
	10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- 1e -- 
	20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	70: -- -- -- -- -- -- -- -- 

```
###Install Think Bowl I2C libraries for Python
For setting up the python library please input following lines: 

```
	cd code/
	mkdir i2c
	cd i2c/
	git clone https://github.com/quick2wire/quick2wire-python-api.git
	export QUICK2WIRE_API_HOME=~/code/i2c/quick2wire-python-api/
	export PYTHONPATH=$PYTHONPATH:$QUICK2WIRE_API_HOME
	mkdir pythoncode
	cd pythoncode/
	git clone https://bitbucket.org/thinkbowl/i2clibraries.git

```
###Wiring:


```
| Pi pin number | Pi pin name 	| HMC5883L pin name  	|
| ------ 	| ------	| -----: 		|
|  1		|  3V3		|   VCC			|
|  6		|  Ground	|   GND			|
|  3		|  SDA		|   SDA			|
|  5		|  SCL		|   SCL			|


```
###Python code

```
	vim test-sensor.py
	python3 test-sensor.py 

```
test-sensor.py should be like following:
{% codeblock test-sensor.py-test-sensor.py %}
#!/usr/bin/python3
from i2clibraries import i2c_hmc5883l
hmc5883l = i2c_hmc5883l.i2c_hmc5883l(0)
hmc5883l.setContinuousMode()
hmc5883l.setDeclination(9,54)
print(hmc5883l)
{% endcodeblock %}
Result should be shown as following:

```
	root@rasp:~/code/i2c/pythoncode# python3 test-sensor.py 
	Axis X: 311.88
	Axis Y: 160.08
	Axis Z: -300.84
	Declination: 9° 54'
	Heading: 37° 4'

```


