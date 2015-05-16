---
layout: post
title: "HMC5883L on RaspberryPI(2)"
date: 2014-01-09 11:13
comments: true
categories: Raspberry PI
---
Here are some explanation on the code in "HMC5883L on RaspberryPI".     
The i2clibraries calls the "quick2wire" library. 

```
	root@rasp:~/code/i2c/pythoncode# grep "quick2wire" ./ -r
	./i2clibraries/i2c.py:from quick2wire.i2c import I2CMaster, writing_bytes, reading
	Binary file ./i2clibraries/__pycache__/i2c.cpython-32.pyc matches
	Binary file ./i2clibraries/i2c.pyc matches

```
So we have to include QUICK2WIRE_API_HOME into the PYTHONPATH:

```
	export QUICK2WIRE_API_HOME=~/code/i2c/quick2wire-python-api/
	export PYTHONPATH=$PYTHONPATH:$QUICK2WIRE_API_HOME

```
So notice you have to specify the correct directory which contains the corresponding code. 

```
	root@rasp:~/code/i2c# tree -d
	.
	├── pythoncode
	│   └── i2clibraries
	│       └── __pycache__
	└── quick2wire-python-api
	    ├── doc
	    ├── examples
	    ├── quick2wire
	    │   ├── helpers
	    │   ├── parts
	    │   └── __pycache__
	    └── tools
	
	11 directories

```
	
