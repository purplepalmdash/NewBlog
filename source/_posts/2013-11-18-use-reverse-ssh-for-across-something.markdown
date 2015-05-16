---
layout: post
title: "Use Reverse SSH for Across Something"
date: 2013-11-18 19:01
comments: true
categories: OpenWRT Linux
---
###Enable No Password for Login 
Generate the public/private rsa key pair. 

```
	root@OpenWrt:~# ssh-keygen -t rsa
	root@OpenWrt:~# ls ~/.ssh
	authorized_keys  id_rsa           id_rsa.pub       known_hosts
Upload the id_rsa.pub to the Home's PC.
	# cat .ssh/id_rsa.pub | ssh USER@HOME_PC 'cat >> .ssh/authorized_keys'
Check If you can login without entering the password:
	$ ssh USER@HOME_PC

```
###OpenWRT Modification
Since the default ssh client is dropbear on OpenWRT, thus the key length is 1024, we have to using the 2048 for most of the cases. so we have to remove dropbear, and install openssh-client for linking to our home PC.    
Change the /etc/init.d/dropbear's listenning port from 22 to 2222 or other ports, this doesn't matter, for later we will totally remove the dropbear.     
Now remove the dropbear

```
	$ opkg remove dropbear

```
Install the packages of openssh:

```
	$ opkg install openssh-client openssh-sftp-client sshtunnel openssh-keygen
	$ opkg install openssh-client-utils

```
Now using " ssh-keygen -t rsa"  we will  get the following:

```
	+--[ RSA 2048]----+

```
But previous we got is:

```
	+--[ DSA 1024]----+

```
That's why we can't use dropbear for login to HOME PC. 
###autossh Configuration
Install autossh on your own OpenWRT

```
	$ opkg install autossh

```
Edit the configuration file:

```
	root@OpenWrt:~# cat /etc/config/autossh 
	config autossh
		option ssh	'-N -T -R 4381:localhost:22 root@goewugouog.gowugoeug.com '
		option gatetime	'0'
		option monitorport	'20000'
		option poll	'600'

```
Start the server immediately, later it will be started automatically:

```
	$ /etc/init.d/autossh start

```
###Jump to the Open World!!!
Jump to the American Server on OpenWRT:

```
	$ ssh -L 13@.XXX.XXX.XXX:9004:13g.XXX.XXX.XXX:8000 fXXXXXX@remote.american.com

```
From Home machine Jump to the OpenWRT in company:

```
	$ ssh -L 10.0.0.111:9001:13@.XXX.XXX.XXX:9004 root@localhost -p 4381

```
Now the connection has been setup between your family network to company network, finally to the US network. 

Enjoy Jumping!!!
###How to make it automatically?
Maybe I can write the script to make it automatically executed.   Via python or via expect? Maybe try python. 
