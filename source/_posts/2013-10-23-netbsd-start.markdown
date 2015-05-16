---
layout: post
title: "NetBSD Start"
date: 2013-10-23 11:58
comments: true
categories: Unix
---
###Installation and Configuration
Download the install.iso and install it in the virtualbox.   
Then add http_proxy, https_proxy, ftp_proxy, ftps_proxy into the .profile file.   
visudo add the current user to the sudo list, then add Defaults env_keep to the http_proxy, etc, because we want to use pkg_add under the sudo priviledge.  

###Updating the software repository snapshot
Edit the Package path via:

```
	 export PKG_PATH=ftp://filedump.se.rit.edu/pub/OpenBSD/5.3/`machine -a`/
```

Update the ports configuration database:

```
	$ cd /tmp
	$ ftp ftp://filedump.se.rit.edu/pub/OpenBSD/5.3/ports.tar.gz
	$ cd /usr
	$ sudo tar xzf /tmp/ports.tar.gz
```
Now you got the updated port information. 

###Search and install specified packages via ports system
Take vim installation for example:  

```
	$ cd /usr/ports
	$ make key=vim describe
	$ make search key=****
	$ cd /usr/ports/editors/vim
	$ sudo make install
	or
	$ sudo make install clean clean-depends
```

Then the ports will take a long,long time to download all of the packages and start to build. Strangely, this command installed gvim into the system.


