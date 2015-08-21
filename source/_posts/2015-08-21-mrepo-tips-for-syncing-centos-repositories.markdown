---
layout: post
title: "mrepo tips for syncing CentOS repositories"
date: 2015-08-21 14:48:30 +0800
comments: true
categories: Linux
---
Refers to the mirrorlist website, don't use aliyun, cause their webserver will
forbidden lftp from fetching the infos. I switches to 163.com and ustc.edu.cn for
different repositories, following are the configuration file.

### CentOS6
An example is listed as:    

```
# cat /etc/mrepo.conf.d/centos6.conf 
[centos6]
name = CentOS $release ($arch)
release = 6
arch = x86_64
metadata = yum repomd

#iso = http://mirrors.163.com/centos/$release/isos/$arch/CentOS-6.6-x86_64-bin-DVD?.iso
# os = http://mirrors.163.com/centos/$release/os/$arch/Packages/ 
# updates = http://mirrors.163.com/centos/$release/updates/$arch/Packages/
# extras = http://mirrors.163.com/centos/$release/extras/$arch/Packages/
# fasttrack = http://mirrors.163.com/centos/$release/fasttrack/$arch/Packages/
# contrib = http://mirrors.163.com/centos/$release/contrib/$arch/Packages/
# centosplus = http://mirrors.163.com/centos/$release/centosplus/$arch/Packages/
epel = http://mirrors.ustc.edu.cn/epel/$release/$arch/

```

### CentOS7
An example is listed as:    

```
# cat /etc/mrepo.conf.d/centos7.conf 
[centos7]
name = CentOS $release ($arch)
release = 7
arch = x86_64
metadata = yum repomd

#iso = http://mirrors.163.com/centos/$release/isos/$arch/CentOS-7.0-1406-x86_64-DVD.iso
os = http://mirrors.163.com/centos/$release/os/$arch/Packages/ 
updates = http://mirrors.163.com/centos/$release/updates/$arch/Packages/
epel = http://mirrors.ustc.edu.cn/epel/$release/$arch/
extras = http://mirrors.163.com/centos/$release/extras/$arch/Packages/
fasttrack = http://mirrors.163.com/centos/$release/fasttrack/$arch/Packages/
contrib = http://mirrors.163.com/centos/$release/contrib/$arch/Packages/
centosplus = http://mirrors.163.com/centos/$release/centosplus/$arch/Packages/
```

Sync via:    

```
$ mrepo -g -u -vvv centos6 && mrepo -g -u -vvv centos7
```
