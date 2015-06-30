---
layout: post
title: "Setup CentOS6/7 Local Repository"
date: 2015-05-20 11:32:56 +0800
comments: true
categories: linux
---
For speeding up the deployment, I have to setup the local repository for CentOS6/7, following is the steps for setting up such two repositories.    
The steps are followed by following URL:    
[https://support.opennodecloud.com/wiki/doku.php?id=usrdoc:os:repomirror](https://support.opennodecloud.com/wiki/doku.php?id=usrdoc:os:repomirror)    


```
# cd /etc/yum.repos.d/
# curl -O https://copr.fedoraproject.org/coprs/baurzhanm/mrepo/repo/epel-6/baurzhanm-mrepo-epel-6.repo
# vim baurzhanm-mrepo-epel-6.repo
# yum update
# yum -y install screen lftp httpd mrepo
# vim mrepo.conf
    ### Configuration file for mrepo
    
    ### The [main] section allows to override mrepo's default settings
    ### The mrepo-example.conf gives an overview of all the possible settings
    [main]
    srcdir = /var/mrepo
    wwwdir = /var/www/mrepo
    confdir = /etc/mrepo.conf.d
    arch = x86_64
    
    mailto = root@localhost
    smtp-server = localhost
    
    #rhnlogin = username:password
    
    ### Any other section is considered a definition for a distribution
    ### You can put distribution sections in /etc/mrepo.conf.d/
    ### Examples can be found in the documentation at:
    ###     /usr/share/doc/mrepo-0.8.9/dists/.
```

Add the configuration files for CentOS 6:    

```
# vim  /etc/mrepo.conf.d/centos6.conf
[centos6]
name = CentOS $release ($arch)
release = 6
arch = x86_64
metadata = yum repomd

#iso = http://mirrors.aliyun.com/centos/$release/isos/$arch/CentOS-6.6-x86_64-bin-DVD?.iso
#os = http://mirrors.aliyun.com/centos/$release/os/$arch/Packages/ 
#updates = http://mirrors.aliyun.com/centos/$release/updates/$arch/Packages/
extras = http://mirrors.aliyun.com/centos/$release/extras/$arch/Packages/
epel = http://mirrors.aliyun.com/epel/$release/$arch/
```

Add configuraiton files for CentOS 7:    

```
# vim  /etc/mrepo.conf.d/centos7.conf
[centos7]
name = CentOS $release ($arch)
release = 7
arch = x86_64
metadata = yum repomd

#iso = http://mirrors.aliyun.com/centos/$release/isos/$arch/CentOS-7.0-1406-x86_64-DVD.iso
#os = http://mirrors.aliyun.com/centos/$release/os/$arch/Packages/ 
#updates = http://mirrors.aliyun.com/centos/$release/updates/$arch/Packages/
#epel = http://mirrors.aliyun.com/epel/$release/$arch/
extra=http://mirrors.aliyun.com/centos/$release/extras/$arch/Packages/
```

Use following comands for initial sync, it will take a very~long~long~long time.    

```
# mrepo -g -u -vvv [centos6|centos7]
```

After syncing, add definition into the apache's configuration:    

```
# vi /etc/httpd/conf.d/mrepo.conf
--- ADD ---
AddDescription "CentOS 6 for x86" centos6-i386
AddDescription "CentOS 6 for x86_64" centos6-x86_64
AddDescription "CentOS 7 for x86" centos7-i386
AddDescription "CentOS 7 for x86_64" centos7-x86_64
--- ADD ---
# Add repofile for CentOS 6 mirror
cat << 'EOF' > /var/www/mrepo/centos6-x86_64/CentOS-local-http.repo 
#
# CentOS-local-http.repo
#
 
[0-base]
name=CentOS-local-base
baseurl=http://mirror.local.int/mrepo/centos6-x86_64/RPMS.os/
gpgcheck=0
 
[0-updates]
name=CentOS-local-updates
baseurl=http://mirror.local.int/mrepo/centos6-x86_64/RPMS.updates/
gpgcheck=0
EOF
 
# Add repofile for CentOS 7 mirror
cat << 'EOF' > /var/www/mrepo/centos7-x86_64/CentOS-local-http.repo 
#
# CentOS-local-http.repo
#
 
[0-base]
name=CentOS-local-base
baseurl=http://mirror.local.int/mrepo/centos7-x86_64/RPMS.os/
gpgcheck=0
 
[0-updates]
name=CentOS-local-updates
baseurl=http://mirror.local.int/mrepo/centos7-x86_64/RPMS.updates/
gpgcheck=0
EOF
 
# chkconfig httpd on
# service httpd restart

```


### mrepo for CentOS6.5

```
[root:/home/juju/mrepo]# cat /etc/mrepo.conf.d/centos6.5.conf  
### URL: http://www.centos.org/
 
[centos6.5]
name = CentOS $release ($arch)
release = 6.5
arch = x86_64
metadata = yum repomd

os=http://vault.centos.org/$release/os/$arch/Packages/
updates=http://vault.centos.org/$release/updates/$arch/Packages/
extras=http://vault.centos.org/$release/extras/$arch/Packages/
centosplus=http://vault.centos.org/$release/centosplus/$arch/Packages/
fasttrack=http://vault.centos.org/$release/fasttrack/$arch/Packages/
```

sync the repository via:    

```
# mrepo -g -u -vvv centos6.5
```
