---
layout: post
title: "Build Contrial Source Code"
date: 2015-01-29 01:44
comments: true
categories: virtualization
---
### Reference
[http://juniper.github.io/contrail-vnc/README.html](http://juniper.github.io/contrail-vnc/README.html)     
### Hardware && Software
Vitualized machine which have 1G memory and 1 core.     
Running 12.04:     

```
# cat /etc/issue
Ubuntu 12.04.3 LTS \n \l

```
### Packages
You should install following packages:    

```
$ sudo add-apt-repository ppa:opencontrail/ppa
$ sudo vim /etc/apt/source.lists
deb http://ppa.launchpad.net/opencontrail/ppa/ubuntu precise main
deb-src http://ppa.launchpad.net/opencontrail/ppa/ubuntu precise main
$ sudo apt-get install  -y scons git python-lxml wget gcc patch make unzip flex bison g++ libssl-dev autoconf automake libtool pkg-config vim python-dev python-setuptools libprotobuf-dev protobuf-compiler libsnmp-python libgettextpo0 libxml2-utils debhelper python-sphinx ruby-ronn libipfix python-all libpcap-dev module-assistant libtbb-dev libboost-dev liblog4cplus-dev libghc-curl-dev
$ sudo apt-get install python-pip
$ sudo pip install gevent bottle netaddr 

```

### Getting Source Code
Use repo for getting the source code:    

```
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
$ echo "export PATH=/usr/local/git/bin:$PATH">>~/.bashrc
$ source ~/.bashrc

```
Fetch the repository and sync it.    

```
$ mkdir ~/Code/OpenContrail
$ cd ~/Code/OpenContrail
$ repo init -u git@github.com:Juniper/contrail-vnc
$ repo sync

```
Some of the packages will be blocked by GFW, be sure you use proxy for downloading them.    
Fetch the third party packages:    

```
$ python third_party/fetch_packages.py

```
### Build the OpenContrail & Pakages
The build step is simply via `scons`, after a long wait, it will pass.     
Generate packages via:    

```
$ make -f packages.make

```
The default configuration will make `all` of the components in packages.make, or you could seperately build single component.    
