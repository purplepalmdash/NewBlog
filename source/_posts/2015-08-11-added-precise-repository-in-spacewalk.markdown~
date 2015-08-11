---
layout: post
title: "Added Precise Repository In SpaceWalk"
date: 2015-08-11 16:26:32 +0800
comments: true
categories: Virtualization
---
### SpaceWalk Backend Configruation
First Create the Channel:    
![/images/2015_08_11_16_27_35_420x157.jpg](/images/2015_08_11_16_27_35_420x157.jpg)    
Then Create the Repository like following:    
![/images/2015_08_11_16_28_21_562x226.jpg](/images/2015_08_11_16_28_21_562x226.jpg)   
Associate the channel together with repository:    
![/images/2015_08_11_16_29_33_659x385.jpg](/images/2015_08_11_16_29_33_659x385.jpg)   
### Install packages
Do following for the prerequisition for syncing the repository.   

```
# yum update python-debian
# vim  /usr/lib/python2.6/site-packages/debian/debfile.py 
PART_EXTS = ['gz', 'xz', 'lzma']
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# rpm -ivh epel-release-6-8.noarch.rpm
# cat epel-testing.repo  | more
[epel-testing]
name=Extra Packages for Enterprise Linux 6 - Testing - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/testing/6/$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=testing-epel6&arch=$basearch
baseurl=http://mirrors.aliyun.com/epel/testing/6/x86_64/
failovermethod=priority
```

### Sync With Local Repository
An example of precise-backports is listed like following, take this example for
example, create other 3 shell scripts:    

```
# cat precise-backports.sh
until spacewalk-debian-sync.pl --username xxxxx --password xxxxxx --channel 'precise-backports' --url 'http://192.168.0.79/ubuntu/dists/precise-backports/main/binary-amd64/'
do
        echo "retry again"
        sleep 30
done
# ls *.sh
precise-backports.sh  precise-security.sh  precise.sh  precise-update.sh
``` 
Sync repository via `sh precise-backports.sh` or other scripts.    

After a long while, you repository will be updated.     
