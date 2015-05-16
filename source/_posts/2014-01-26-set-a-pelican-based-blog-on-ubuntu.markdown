---
layout: post
title: "Set a pelican based blog on Ubuntu"
date: 2014-01-26 16:39
comments: true
categories: pelican
---
Install python-virtualenv:

```
	sudo apt-get install python-virtualenv

```
Install the virtualenv Wrapper:

```
	sudo apt-get install virtualenvwrapper

```
Now create the directory for holding the virtual environment:

```
	mkdir ~/pyv

```
Edit the virtualenv resource file:

```
	export WORKON_HOME="/home/Trusty/pyv"
	export PROJECT_HOME="/home/Trusty/pyv"
	#source /usr/bin/virtualenvwrapper.sh

```
Here we meet the problem, it says cannot find the /usr/bin/virtualenvwrapper.sh, I got the answer from the stackoverflow: 

```
	From /usr/share/doc/virtualenvwrapper/README.Debian:
	
	In contrast to the information in
	/usr/share/doc/virtualenvwrapper/en/html/index.html this package installs
	virtualenvwrapper.sh as /etc/bash_completion.d/virtualenvwrapper.
	
	Virtualenvwrapper is enabled if you install the package bash-completion and
	enable bash completion support in /etc/bash.bashrc or your ~/.bashrc.
	
	If you only want to use virtualenvwrapper you may just add
	
	 source /etc/bash_completion.d/virtualenvwrapper
	
	to your ~/.bashrc.

```
So the right command should be: 

```
	$ cat /home/Trusty/.virtualenvrc 
	export WORKON_HOME="/home/Trusty/pyv"
	export PROJECT_HOME="/home/Trusty/pyv"
	source /etc/bash_completion.d/virtualenvwrapper

```
Now add this find into .bashrc and source~/.bashrc again:

```
	$ tail -1 ~/.bashrc 
	source /home/Trusty/.virtualenvrc
	$ source ~/.bashrc	

```
Good!!! Now you can continue with the following steps, just as we noticed in previous articles. 
