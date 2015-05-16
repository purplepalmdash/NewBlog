---
layout: post
title: "Configure samba server on Ubuntu"
date: 2013-12-02 09:38
comments: true
categories: Linux
---
###Installation
Update repository and install samba and samba services.

```
	$ sudo apt-get update
	$ sudo apt-get install samba smbfs

```
###Configuration
Add a new samba user:

```
	Trusty@joggler:~$ sudo smbpasswd -a Trusty
	[sudo] password for Trusty: 
	New SMB password:
	Retype new SMB password:

```
Editing the /etc/samba/smb.conf:

```

	[samba]
	   comment = samba for ethernet users
	   path = /media/samba
	   valid users = Trusty
	   public = no
	   writable = yes
	   printable = no
	   create mask = 0765

	[homes]
	   comment = Home Directories
	   browseable = no

	security = user
	username map = /etc/samba/smbusers

```

Adding the mapping of the system user to samba user:

```
	Trusty@joggler:/media$ cat /etc/samba/smbusers 
	Trusty="Trusty"

```

Restarting the samba service and now you can login with your new username and password.
###Configure easy
swat for samba, its description is listed as:    
swat - Samba Web Administration Tool     

```
	$ sudo apt-get install swat xinetd

```
edit the configuration files:

```
	Trusty@joggler:/etc/samba$ cat /etc/xinetd.d/swat 
	# description: SWAT is the Samba Web Admin Tool. Use swat \
	#              to configure your Samba server. To use SWAT, \
	#              connect to port 901 with your favorite web browser.
	service swat
	{
	        port    = 901
	        socket_type     = stream
	        wait    = no
	        user    = root
	        server  = /usr/sbin/swat
	        log_on_failure  += USERID
	        disable = no
	}

```
After restart xinetd, we can access http://YourIP:901 for configuration. 
###Mount the samba partition
We can add this line to the ~/.bashrc, then use mountsamba we could mount the samba disk to our own mounting point.    

```
	alias mountsamba='sudo mount -t cifs //10.0.0.11/samba1/ -o user=Trusty,password=Trustywill,workgroup=WORKGROUP /media/samba'

```
On Windows it's very convinient to mount the shared samba, but on Linux, only root could write to the samba disk , why?     
###NFS
Installation: 

```
	$ sudo apt-get install nfs-kernel-server
	$ sudo apt-get install rpcbind

```
Configuration of the nfs server:

```
	Trusty@joggler:~$ cat /etc/exports 
	/home/Trusty 10.0.0.221(rw,sync,no_subtree_check) 10.0.0.11(rw,sync,no_subtree_check)
Restart the service of nfs:
	$ sudo service nfs-kernel-server restart
In client machine, Just add following lines to your /etc/fstab
	10.0.0.11:/home/Trusty   /media/nfs   nfs4   rsize=8192,wsize=8192,timeo=14,intr,_netdev	0 0
```
Restart and now in your own /media/nfs you will see the destination nfs directory. 

