---
layout: post
title: "How python interact with RaspberryPI GPIO"
date: 2013-10-12 10:06
comments: true
categories: Linux Driver
---
Yesterday I use RaspberryPI to control the LED using its GPIO port.  with Python code we can directly "talk" to RaspberryPI, and set LED on and off. But what is the principle in it?  How to realize our own library(for example, python/perl/lua based library?), here I will dive into the python library code and find what's really inside the python code.

###Prepare the environment
Install the RPi.GPIO via pip, $ pip install RPi,GPIO .    
After installed the GPIO library, we can insert help('modules') in python shell/prompt window to view all of the installed modules, we could found RPi in the list of the packages.  

We can found the corresponding packages under the installation directory of python, so first you have to find the location of your python executable file, use "which python" to find the destination of the python.  
For example, my RPi installed location is under: /home/Trusty/.virtualenvs/venv2/lib/python2.7/site-packages, not in the standard directory, because the python runs in the virtual environment.   

###How to control the GPIO in UserSpace.
Controlling GPIO in shell :

```
	root@rasp:~# echo 18 > /sys/class/gpio/export 
	root@rasp:~# ls /sys/class/gpio/
	export  gpio18  gpiochip0  unexport
	root@rasp:~# echo "out" > /sys/class/gpio/gpio18/direction 
	root@rasp:~# echo 1 > /sys/class/gpio/gpio18/value 
	root@rasp:~# 
	root@rasp:~# echo 23 > /sys/class/gpio/export 
	root@rasp:~# ls /sys/class/gpio/
	export  gpio18  gpio23  gpiochip0  unexport
	root@rasp:~# echo "out" >/sys/class/gpio/gpio23/direction 
	root@rasp:~# echo 1>/sys/class/gpio/gpio23/value 
	-bash: echo: write error: Invalid argument
	root@rasp:~# echo 1 > /sys/class/gpio/gpio23/value 
	root@rasp:~# echo 0 > /sys/class/gpio/gpio23/value 
	root@rasp:~# echo 0 > /sys/class/gpio/gpio18/value 
```

So we can see, the standard procedure is: write exported gpio number to export file--> write direction to gpioXX's direction--> write value to the gpioxx's value. The python script wrapped the upper procedures, so we directly call them in python written scripts. 
