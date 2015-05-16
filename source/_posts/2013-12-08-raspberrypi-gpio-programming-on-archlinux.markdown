---
layout: post
title: "raspberryPI GPIO Programming on ArchLinux"
date: 2013-12-08 15:26
comments: true
categories: Linux embedded
---
###Python Preparation
Install python

```
	$ pacman -S python

```
Install pip

```
	$ pacman -S python-pip

```
Install virtualenv, before install virtualenv, be sure to update your time. 1970's time will get ssl error. 

```
	$ date -s "8 Dec 2013 16:09:40"
	$ pip install --upgrade virtualenv virtualenvwrapper

```
Prepare virtualenv:

```
	[root@alarmpi ~]# mkdir ~/pyv
	[root@alarmpi ~]# vim ~/.virtualenvrc
	export WORKON_HOME="/root/pyv"
	export PROJECT_HOME="/root/pyv"
	source /usr/bin/virtualenvwrapper.sh 
	[root@alarmpi ~]# source ~/.virtualenvrc

```
Now your virtualenv is OK. Make a virtualenv for python2.7

```
	$ mkvirtualenv --python=/usr/bin/python2.7 v27
	cdvirtualenv

```
Add environment variables into your ~/.bashrc

```
	export WORKON_HOME=$HOME/pyv
	export PIP_VIRTUALENV_BASE=$WORKON_HOME
	source /usr/bin/virtualenvwrapper.sh

```
Next time if you want to enter virtualenv, simply type: 

```
	$ workon v27

```
Install rpi.gpio

```
	$ pip install rpi.gpio

```
###Use rpi.gpio on raspberryPI
TBD. I don't know why but my raspberyPI can't work properly on 1602 LCD. So I begin to test GPIO
###Use WiringPi for programming
Preparation:

```
	$ pacman -S git gcc make

```
Download the packages:

```
	$ git clone git://git.drogon.net/wiringPi
	$ cd wiringPi
	$ git pull origin
	$ ./build

```
Testing the WiringPi:

```
	[root@alarmpi gpio]# ./gpio readall
	+----------+-Rev1-+------+--------+------+-------+
	| wiringPi | GPIO | Phys | Name   | Mode | Value |
	+----------+------+------+--------+------+-------+
	|      0   |  17  |  11  | GPIO 0 | OUT  | High  |
	|      1   |  18  |  12  | GPIO 1 | IN   | Low   |
	|      2   |  21  |  13  | GPIO 2 | IN   | Low   |
	|      3   |  22  |  15  | GPIO 3 | IN   | Low   |
	|      4   |  23  |  16  | GPIO 4 | IN   | Low   |
	|      5   |  24  |  18  | GPIO 5 | IN   | Low   |
	|      6   |  25  |  22  | GPIO 6 | IN   | Low   |
	|      7   |   4  |   7  | GPIO 7 | IN   | Low   |
	|      8   |   0  |   3  | SDA    | ALT0 | High  |
	|      9   |   1  |   5  | SCL    | ALT0 | High  |
	|     10   |   8  |  24  | CE0    | ALT0 | High  |
	|     11   |   7  |  26  | CE1    | ALT0 | High  |
	|     12   |  10  |  19  | MOSI   | ALT0 | Low   |
	|     13   |   9  |  21  | MISO   | ALT0 | Low   |
	|     14   |  11  |  23  | SCLK   | ALT0 | Low   |
	|     15   |  14  |   8  | TxD    | ALT0 | High  |
	|     16   |  15  |  10  | RxD    | ALT0 | High  |
	+----------+------+------+--------+------+-------+

```
Simply testing a LED tutorial:    
Wiring image:    
![sourceledgpio.jpg](/images/ledgpio.jpg)

Then Writing following script:

```sh autoshining.sh
#!/bin/bash
/root/wiringPi/gpio/gpio mode 0 out
while true then
do
	/root/wiringPi/gpio/gpio write 0 1
	sleep 1
	/root/wiringPi/gpio/gpio write 0 0
	sleep 1
done

```
Now you will get a shining LED. 

