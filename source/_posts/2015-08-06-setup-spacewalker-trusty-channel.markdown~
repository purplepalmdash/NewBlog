---
layout: post
title: "Setup SpaceWalker Trusty Channel"
date: 2015-08-06 11:47:31 +0800
comments: true
categories: Virtualization
---
### Channel Definition
The definition for this channel should includes Architecture to 'amd64-debian', and Yum
Repository to SHA256:    

Yum Repository Checksum Type
sha256
Architecture
AMD64 Debian

### Channel Definition
The definition for this channel should includes Architecture to 'amd64-debian', and Yum
Repository to SHA256:    

```
Yum Repository Checksum Type
sha256
Architecture
AMD64 Debian
```

Then create more channels with its parent channel to your named channel.   

![/images/2015_08_06_11_54_16_776x378.jpg](/images/2015_08_06_11_54_16_776x378.jpg)    

Also create `trusty-security` and `trusty-backports`, after all configuration, your
channel would be looks like following:    

![/images/2015_08_06_11_57_47_649x191.jpg](/images/2015_08_06_11_57_47_649x191.jpg)    

Enable epel-testing and install python-debian:    

```
# wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
# rpm -ivh epel-release-7-5.noarch.rpm 
# yum-config-manager --enable epel-testing 
# cat epel-testing.repo
    [epel-testing]
    name=Extra Packages for Enterprise Linux 7 - Testing - $basearch
    #baseurl=http://download.fedoraproject.org/pub/epel/testing/7/$basearch
    #mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=testing-epel7&arch=$basearch
    baseurl=http://mirrors.aliyun.com/epel/testing/7/x86_64/
# yum update python-debian
```
Patch the `debfile.py`:    

```
# vim /usr/lib/python2.7/site-packages/debian/debfile.py
- PART_EXTS = ['gz', 'bz2', 'xz']   # possible extensions
+ PART_EXTS = ['gz', 'bz2', 'xz', 'lzma']   # possible extensions
```

Repo sync:    

```
# git clone https://github.com/stevemeier/spacewalk-debian-sync.git
# cd spacewalk-debian-sync/
# mv spacewalk-debian-sync.pl /usr/bin/
# chmod 777 /usr/bin/spacewalk-debian-sync.pl
# yum install perl-WWW-Mechanize
```
Now sync the repository from remote server:    

```
spacewalk-debian-sync.pl --username xxxxx --password xxxxx --channel 'trusty-backports' --url 'http://192.168.0.79/ubuntu/dists/trusty-backports/main/binary-amd64/'
```
After the sync finished, the channel will be setup.   
