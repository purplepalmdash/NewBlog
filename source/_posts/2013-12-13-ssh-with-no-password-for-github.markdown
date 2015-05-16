---
layout: post
title: "ssh with no password for github"
date: 2013-12-13 17:07
comments: true
categories: Linux
---
###Github Account Setting
Steps for settingup in your github accounting:    
Go to your Settings.     
Click "SSH Keys" in the left sidebar    
Click "Add SSH key"     
Paste your key into the "Key" field     
Click "Add key"     
Confirm the action by entering your GitHub password     


The public key could be got via:

```
	$ xclip -sel clip < ~/.ssh/id_rsa.pub

```
Then see if you were authorized by github: 

```
	[Trusty@XXXyyy debian_octopress]$ ssh -T git@github.com
	Hi geogueo! You've successfully authenticated, but GitHub does not provide shell access.

```
###Setting for repository
Add the remote url for local repository

```
	[Trusty@XXXyyy debian_octopress]$ git remote set-url origin git@github.com:geogueo/debian_octopress.git

```
Now you can use the following command for swiftly commit your code

```
	[Trusty@XXXyyy debian_octopress]$ unset SSH_ASKPASS
	[Trusty@XXXyyy debian_octopress]$ git push origin master
	Warning: Permanently added the RSA host key for IP address '192.30.252.129' to the list of known hosts.
	Everything up-to-date

```
