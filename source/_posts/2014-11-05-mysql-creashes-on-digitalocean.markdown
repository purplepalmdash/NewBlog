---
layout: post
title: "MySQL creashes on DigitalOcean"
date: 2014-11-05 13:51
comments: true
categories: Linux
---
### Problem
The mysql server always keep crash, with following log under /var/log/mysql/error.log:    

```
141104 23:06:46 InnoDB: Fatal error: cannot allocate memory for the buffer pool

```
So this is the memory problem, we should allocate more memory for our VPS.    
### Solution
Add swap partition:     
First check the swap partition:    

```
root@xxx:/var/log# free -m
             total       used       free     shared    buffers     cached
Mem:           490        464         25         28         61        172
-/+ buffers/cache:        230        259
Swap:            0          0          0
root@xxx:/var/log# swapon -s
Filename                                Type            Size    Used    Priority

```
Now create a swapfile:    

```
# dd if=/dev/zero of=/swapfile bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 2.16285 s, 496 MB/s
# ls /swapfile -l -h
-rw-r--r-- 1 root root 1.0G Nov  5 00:58 /swapfile

```
Setting the swapfile:     

```
root@xxx:/var/log# chmod 600 /swapfile 
root@xxx:/var/log# swapon /swapfile
swapon: /swapfile: read swap header failed: Invalid argument
root@xxx:/var/log# mkswap /swapfile
Setting up swapspace version 1, size = 1048572 KiB
no label, UUID=64b727dd-0d7e-45ff-9235-cd9ba84b062f
root@xxx:/var/log# swapon /swapfile 

```
Now use free command you could check swap file enabled:     

```
root@xxx:/var/log# free -m
             total       used       free     shared    buffers     cached
Mem:           490        458         31         28         25        229
-/+ buffers/cache:        204        285
Swap:         1023          0       1023

```
Add it permanately into the /etc/fstab:    

```
/swapfile   none    swap    sw    0   0

```
Configure the parameters:    

```
root@xxx:/var/log# cat /proc/sys/vm/swappiness
60
root@xxx:/var/log# sysctl vm.swappiness=10
vm.swappiness = 10                                                                                      
root@xxx:/var/log# cat /proc/sys/vm/swappiness                                                  
10                                                
root@xxx:/var/log# vim /etc/sysctl.conf
vm.swappiness=10
vm.vfs_cache_pressure = 50
root@xxx:/var/log# cat /proc/sys/vm/vfs_cache_pressure                                          
100                                         
root@xxx:/var/log# cat /proc/sys/vm/vfs_cache_pressure                                          
50                                                                                                     

```
Now the mysql server should be good.     


### Disable wp-admin login password
Disable the login password.   

```
# vim /etc/apache2/apache2.conf
#<DirectoryMatch ^.*/wp-admin/>
#    AuthType Basic
#    AuthName "Please login to your droplet via SSH for login details."
#    AuthUserFile /etc/apache2/.htpasswd
#    Require valid-user
#<DirectoryMatch>
root@xxx:~# service apache2 restart
 * Restarting web server apache2      

```
Change the password for login details    

```
$ htpasswd .htpasswd user2

```
