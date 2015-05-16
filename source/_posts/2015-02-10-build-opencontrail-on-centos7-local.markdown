---
layout: post
title: "Build OpenContrail On CentOS7(Local)"
date: 2015-02-10 05:06
comments: true
categories: 
---
Fresh steps.   

```
$ sudo yum update
$ sudo yum install vim
$ sudo yum install net-tools
$ sudo yum install -y scons git python-lxml wget gcc patch make unzip flex bison gcc-c++ openssl-devel autoconf automake vim python-devel python-setuptools protobuf protobuf-devel protobuf-compiler net-snmp-python libtool kernel-devel bzip2 boost-devel tbb-devel libcurl-devel libxml2-devel scons protobuf protobuf-devel protobuf-compiler
$ sudo yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
$ sudo sed -i -e 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
$ sudo yum install -y --disablerepo="*" --enablerepo="epel" scons protobuf protobuf-devel protobuf-compiler 
$ sudo yum install -y bzip2 boost-devel tbb-devel libcurl-devel libxml2-devel 

```
As root, Add repositories:     

```
# wget -q -O - http://www.atomicorp.com/installers/atomic | sh
# yum update
# yum install dpkg dpkg-devel

```
Missing fakeroot, so can't be continue.  

Change back to CentOS 6.6.    

```
$ sudo yum install vim net-tools
$ wget https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
$ sudo rpm -ivh epel-release-6-8.noarch.rpm 
$ sudo yum install -y scons git python-lxml wget gcc patch make unzip flex bison gcc-c++ openssl-devel autoconf automake vim python-devel python-setuptools protobuf protobuf-devel protobuf-compiler net-snmp-python libtool kernel-devel bzip2 boost-devel tbb-devel libcurl-devel libxml2-devel scons protobuf protobuf-devel protobuf-compiler
$ sed -i -e 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
$ yum install -y --disablerepo="*" --enablerepo="epel" scons protobuf protobuf-devel protobuf-compiler  bzip2 boost-devel tbb-devel libcurl-devel libxml2-devel xz

```
Install git:    

```
$ yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
$ wget https://www.kernel.org/pub/software/scm/git/git-1.9.4.tar.gz
$ sudo yum install expat-devel tar
$ make prefix=/usr install
$ which git
git version 1.9.4

```
Using repo sync:     

```
$ repo init -u git@github.com:Juniper/contrail-vnc
$ repo sync

```
Install argparse:    

```
$ yum install python-argparse
$ declare -x USER="root"

```
We should upgrade some packages to let python could fetch back the packages:    

```
$ wget http://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
$ tar xzvf autoconf-latest.tar.gz
$ cd autoconf-2.69/
$ ./configure --prefix=/usr && make && sudo make install
$ sudo yum install libtool

```
Fetch the 3rd_party packages:     

```
$ python third_party/fetch_package.py

```
Then tar and export it to the host machine.   

When Building, we have to install libipfix:    

```
$ wget http://sourceforge.net/projects/libipfix/files/libipfix/libipfix_110209.tgz/download
$ # build it.   

```
Enable the epel repository and install dpkg and dpkg-devel:    

```
$ sudo sed -i -e 's/enabled=0/enabled=1/' /etc/yum.repos.d/epel.repo
$ sudo yum update && sudo yum install -y dpkg dpkg-devel

```

 

