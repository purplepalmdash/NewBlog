---
layout: post
title: "Deploy Weather APP on RaspberryPI"
date: 2014-03-17 20:10
comments: true
categories: RaspberryPI
---
Since I enabled the RaspberryPI and disabled the PogoPlug, I have to move the Weather App on RaspberryPI. <br />
The main difference lies on the python version, on PogoPlug the default python version is python2.7, while on RaspberryPI it's python3.3, thus I have to use the virtualenvironment of Python. <br />

###Setup the virtualenv
Following is the steps for setting up the virtual environment for python2.7 on ArchLinux:<br />

```
	$ mkdir ~/pyves
	$ cat >~/.virtualenvrc <<EOF
	export WORKON_HOME="$HOME/pyves"
	export PROJECT_HOME="$HOME/pyves"
	source /usr/bin/virtualenvwrapper.sh
	EOF
	$ source  ~/.virtualenvrc
	$ cat >>~/.bashrc <<EOF
	source $HOME/.virtualenvrc
	EOF
	$ mkvirtualenv --python=/usr/bin/python2.7 v27
	$ workon v27
	$ pip install pywapi django sqlite3

```
###Deployment Python Script
Copy the script to some directory, mine is under /root/code/weather.<br />
If we want cron to call the virtual environment, we have to create a script and in the script to call the python script.<br />

```sh NJ.sh
	#!/bin/bash
	# Export everything.
	source /root/.bashrc
	# Change to the virtual environment
	workon v27
	# Call python
	python /root/code/weather/genhtml.py

```
Now we add this script to crontab, at every whole point, each hour it will run once. <br />

```
	crontab -e
	0 */1 * * * /root/code/weather/NJ.sh
	15 */1 * * * /root/code/weather/BJ.sh
	30 */1 * * * /root/code/weather/CS.sh

```
Now at every 0/15/30, our cron job will be run, and retrieve the data generate the flot image for displaying.
