---
layout: post
title: "Play Docker(6) -- Using docker for building"
date: 2015-02-09 23:16
comments: true
categories: virtualization
---
The steps is for Ubuntu12.04, the purpose of this documentation is for swiftly get the source code and fetch it to local repository.    
### Preparation
Pull back the Ubuntu12.04:    

```
$ sudo docker pull ubuntu12.04

```
Then run into the ubuntu12.04 via:    

```
$ sudo docker run -it ubuntu12.04 /bin/bash
root@7b30cc924bb0:~ #

```
Install following packages in Ubuntu 12.04 container:     

```
# apt-get install python-software-properties
# apt-get install curl
# curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
# chmod 777 /bin/repo
# apt-get update
# apt-get install python-pip
# apt-get install git
# git config --global user.email kkkttt@gmail.com
# git config --global user.name kkkttt
# ssh -T git@github.com
# repo init -u git@github.com:Juniper/contrail-vnc
# repo sync
# declare -x USER="root"
# apt-get install python-lxml autoconf bzip2 libtool unzip wget 
# python third_party/fetch_packages.py

```
Install nginx:    

```
$ sudo rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
$ sudo rpm -ivh nginx

```
Change nginx's listenning directory to `/var/www/`, tar the directory and put it under this folder, then use firefox for downloading it.    
### Compile Local
Referes to :     
[http://kkkttt.github.io/blog/2015/01/29/build-contrial-source-code/](http://kkkttt.github.io/blog/2015/01/29/build-contrial-source-code/)    
Plus:    

```
$ sudo apt-get install libglib2.0-dev libglib2.0

```

