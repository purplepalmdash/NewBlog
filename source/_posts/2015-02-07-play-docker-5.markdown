---
layout: post
title: "Play Docker(5)"
date: 2015-02-07 04:22
comments: true
categories: Virtualization
---
Since I enabled OpenSuse, later all of the docker related operation could be operated on OpenSuse13.2.     
### Installation
Install docker via:    

```
$ sudo zypper in docker
$ which docker
/usr/bin/docker

```
### Specify Storage Location
The /var directory has the limitation, thus we have to specify the storage locateion in /etc/sysconfig/docker:    

```
$ pwd
/etc/sysconfig
$  cat docker 

## Path           : System/Management
## Description    : Extra cli switches for docker daemon
## Type           : string
## Default        : ""
## ServiceRestart : docker
#
DOCKER_OPTS="-g /home/xxxxxx/Code/Virtualization/Docker/docker/"


```
Now we could use the nearly 2T Size /home partition for storing docker images..     
### Use China Resources
The default dockhub is banned by GFW, so we have to use replacement repository in China.   
Add the options to /ec/sysconfig/docker:    

```
DOCKER_OPTS="-g /home/clouder/Code/Virtualization/Docker/docker/ --insecure-registry dl.dockerpool.com:5000"

```
Then restart the docker via `systemctl restart docker`, after them we could use following command for pull back images:    

```
$ sudo docker pull dl.dockerpool.com:5000/ubuntu:14.04

```
After pull back ,check the name of our fetched back ubuntu:14.04 is:    

```
$ sudo docker images
dl.dockerpool.com:5000/ubuntu            14.04               5506de2b643b        3 months ago        197.8 MB
dl.dockerpool.com:5000/ubuntu            latest              5506de2b643b        3 months ago        197.8 MB

```
Change to a differenet tag name:    

```
$ sudo docker tag dl.dockerpool.com:5000/ubuntu:14.04 ubuntu:14.04

```
Now check again and you will find the long and hard-to-remember name has been changed to `ubuntu:14.04`.    
Our version of docker runs on OpenSuse is:    

```
$ docker --version
Docker version 1.4.1, build 5bc2ff8

```

