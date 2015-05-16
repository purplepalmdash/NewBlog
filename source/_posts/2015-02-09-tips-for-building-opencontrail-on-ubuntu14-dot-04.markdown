---
layout: post
title: "Tips for building opencontrail on Ubuntu14.04"
date: 2015-02-09 01:58
comments: true
categories: linux
---
### Dependencies
Install the following packages to make `scons` getting through:    

```
$ sudo apt-get install -y scons git python-lxml wget gcc patch make unzip flex bison g++ libssl-dev autoconf automake libtool pkg-config vim python-dev python-setuptools libprotobuf-dev protobuf-compiler libsnmp-python libboost-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-program-options-dev libboost-python-dev libboost-regex-dev libboost-system-dev libcurl4-openssl-dev google-mock libgoogle-perftools-dev liblog4cplus-dev libtbb-dev libhttp-parser-dev libxml2-dev libicu-dev
$  sudo apt-get install libxml2-dev
$  sudo apt-get install libboost-dev
$  sudo apt-get install libboost-filesystem-dev
$  sudo apt-get install libboost-program-options-dev
$  sudo apt-get install libboost-system-dev libboost-regex-dev libboost-python-dev libboost-chrono-dev libtbb-dev

```
Then the linking should be OK.   
### Making Packages
Install following packages for meeting the requirements of deb packages:    

```
$ sudo apt-get install libcurl4-openssl-dev libboost-date-time-dev libboost-thread-dev google-mock libgoogle-perftools-dev libhttp-parser-dev

```
Then `make -f packages.make` you could get the generated deb files.    
