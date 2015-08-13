---
layout: post
title: "Create Channel/Repository In SpaceWalk"
date: 2015-08-12 16:36:51 +0800
comments: true
categories: Spacewalk
---
### Package Preparation
First you should enable the repository via:    

```
# wget http://yum.spacewalkproject.org/2.3/RHEL/6/x86_64/spacewalk-repo-2.3-4.el6.noarch.rpm
# rpm -ivh spacewalk-repo-2.3-4.el6.noarch.rpm
# vim /etc/yum.repos.d/jpackage-repo.repo 
[jpackage-generic]
name=JPackage generic
#baseurl=http://mirrors.dotsrc.org/pub/jpackage/5.0/generic/free/
mirrorlist=http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0
enabled=1
gpgcheck=1
gpgkey=http://www.jpackage.org/jpackage.asc
```

Install the `spacewalk-remote-utils` package:   

```
# yum install -y spacewalk-remote-utils
```

### WebUI Create Repository
Create an ia32-debian based channel, in WebUI:   

![/images/2015_08_12_17_22_47_651x391.jpg](/images/2015_08_12_17_22_47_651x391.jpg)   

Continue to create some child channel:    

![/images/2015_08_12_17_26_22_810x155.jpg](/images/2015_08_12_17_26_22_810x155.jpg)    

Now create the repository like following:  

![/images/2015_08_12_17_28_41_796x426.jpg](/images/2015_08_12_17_28_41_796x426.jpg)   

Until you created all of the ia32 based repositories:   

![/images/2015_08_12_17_30_39_609x115.jpg](/images/2015_08_12_17_30_39_609x115.jpg)   

Associate the repository with channels.      
   
### Sync Repositories
Use following scripts for syncing the packages into the system:    

```
# vim precise-update.sh 
until spacewalk-debian-sync.pl --username xxxxx --password xxxx --channel 'precise-ia32-updates' --url 'http://192.168.0.79/ubuntu/dists/precise-updates/main/binary-i386/'
do
        echo "retry again"
        sleep 30
done
# sh precise-update.sh
INFO: Repo URL: http://192.168.0.79/ubuntu/dists/precise-updates/main/binary-i386/
INFO: Ubuntu root is http://192.168.0.79/ubuntu/
INFO: Fetching Packages.gz... done
........
```
