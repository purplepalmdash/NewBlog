---
layout: post
title: "Create a new user for updating qzone"
date: 2014-01-23 19:41
comments: true
categories: pelican
---
###Backgroud
Because github only allow one user to login(trusted key), the error message is listed as "Error: Key already in use", I have to try another method for updating the qzone.     
First I have created a new user on github, and created the corresponding repositories, now I have to create the user on my own machine, named "qzone" for only updating the repository.     
###Create the user
Use following command for create a new user:

```
	useradd -m -g root -G wheel -s /bin/bash qzone
	passwd qzone

```
Then as another oridinary user, run "su qzone" then we can switch to the new user's shell.    
###Configure the user
Configure the git tools:

```
	[qzone@XXXyyy ~]$ git config --global user.name "qzone"
	[qzone@XXXyyy ~]$ git config --global user.email "XXXYYY@qq.com"

```
Add python virtualenv running environment:

```
	mkdir ~/pyv
	[qzone@XXXyyy ~]$ cat ~/.virtualenvrc 
	export WORKON_HOME="/home/qzone/pyv"
	export PROJECT_HOME="/home/qzone/pyv"
	source /usr/bin/virtualenvwrapper.sh 	

```
Add following lines for automatically run virtualenv setup 

```
	$ tail ~/.bashrc
	source /home/qzone/.virtualenvrc

```
Now we can create the virtualenv for running python. 

```
	[qzone@XXXyyy ~]$ mkvirtualenv --python=/usr/bin/python2.7 v27
	$ cdvirtualenv

```
Now we are in the python 2.7 environment. But notice you have to set http_proxy/https_proxy, etc for you are working under the proxy.    
Install the pelican:

```
	$ pip install pelican

```
Add configuration for git proxy:

```
	export GIT_PROXY_COMMAND=/bin/myproxy

```
Add workon directory in .bashrc:

```
	export WORKON_HOME=~/pyv

```
Next time, workon v27 then we can switch to python2.7 shell.    
Make the directory of code, which will store all of the code.    

```
	$ mkdir -p ~/code/XXXYYY

```
Now clone the existing repository into the local directory:

```
	git clone https://github.com/XXXYYY/XXXYYY.github.io

```
Install ghp-import for swiftly deploy your website

```
	pip install ghp-import

```
Now setting:

```
	pelican content -o output -s pelicanconf.py
	ghp-import output
	git push git@github.com:XXXYYY/XXXYYY.github.io.git gh-pages:master

```
Now you will failed, because you don't have the correct access rights. So we need to set the ssh access right:

```
	ssh-keygen -t rsa
	cat ~/.ssh/id_rsa.pub

```
Then in github's accounting management page, add this content.    
Push all of the modifications to the remote repository: 

```
	git push -f git@github.com:XXXYYY/XXXYYY.github.io.git gh-pages:master

```
Install markdown for analyse the markdown based blog:

```
	pip install markdown

```
Now you can do the following:

```
	make html
	make github
	git push -f git@github.com:XXXYYY/XXXYYY.github.io.git gh-pages:master

```
Now install new themes:

```
	cat pelicanconf.py
	# Use theme for our own
	THEME = "./pelican-themes/waterspill-en"

```
OK, now you can enjoy the blog finally. 
