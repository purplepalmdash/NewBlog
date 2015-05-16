---
layout: post
title: "Enable nfs server of 53"
date: 2014-11-05 17:08
comments: true
categories: embedded
---
Only enabled the nfs server and use the max disk for building, the nfs server runs Redhat RHEL6.2, the same procedure could be applied to CentOS Based system.     
Steps:    
Query for installed packages in server:     

```
$ rpm -qa nfs-utils
$ rpm -qa rpcbind

```
Edit the nfs based directory:    

```
# cat /etc/exports
/home/Trusty/share/       *(rw,sync,no_subtree_check,no_root_squash)

```
Start the service and test:   

```
# service rpcbind start
# service nfs start

```
In client machine, just type following command for mount the remote nfs directory:    

```
$ sudo mount -t nfs 1xx.xxx.xxx.xx:/home/Trusty/share /mnt/

```
Make nfs server automatically start when system boot:    

```
# chkconfig nfs on
# chkconfig rpcbind on

```
Client Machine(59), do following for automatically mount nfs:    

```
$ vim /etc/fstab
# Using NFS
1xx.xxx.xxx.xx:/home/Trusty/share /media/nfs/     nfs     rsize=8192,wsize=8192,timeo=14,intr     0       0
$ mount -a

```
Then everytime this clent machine startup the remote nfs directory will be mounted to local directory.     

If you are ubuntu client, then you should install nfs-client via;     

```
sudo apt-get install nfs-common

```
