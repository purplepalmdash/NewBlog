---
layout: post
title: "Setup Local Repository"
date: 2015-05-19 11:57:19 +0800
comments: true
categories: linux
---
### Ubuntu 
After using apt-mirror syncing all of the packages from the repository website, setup a ftp site:    

```
# apt-get install -y proftpd
# cat conf.d/anonymous.conf 
<Anonymous ~ftp>
   User                    ftp
   Group                nogroup
   UserAlias         anonymous ftp
   RequireValidShell        off
#   MaxClients                   10
   <Directory *>
     <Limit WRITE>
       DenyAll
     </Limit>
   </Directory>
 </Anonymous>
#  mount --bind /mnt/myrepo/mirror/mirrors.aliyun.com/ /srv/ftp/
# service proftpd restart
```

Now Open your browser to `ftp://Your_URL/`, you will find the repository available.    

### CentOS Proftpd
Just remember the default directory is located at `/var/ftp`, 

```
# yum install -y proftpd
# mount --bind /mirror/mirrors.aliyun.com/ /var/ftp/
# service proftpd restart
```

### Client Configuration

Replace the URL into your ftp url:    


```
# vim /etc/apt/sources.list
deb ftp://YourURL/ubuntu/ trusty main restricted universe multiverse
deb ftp://YourURL/ubuntu/ trusty-security main restricted universe multiverse
deb ftp://YourURL/ubuntu/ trusty-updates main restricted universe multiverse
deb ftp://YourURL/ubuntu/ trusty-proposed main restricted universe multiverse
deb ftp://YourURL/ubuntu/ trusty-backports main restricted universe multiverse
deb-src ftp://YourURL/ubuntu/ trusty main restricted universe multiverse
deb-src ftp://YourURL/ubuntu/ trusty-security main restricted universe multiverse
deb-src ftp://YourURL/ubuntu/ trusty-updates main restricted universe multiverse
deb-src ftp://YourURL/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src ftp://YourURL/ubuntu/ trusty-backports main restricted universe multiverse
# apt-get update && apt-get upgrade 
```

Using local repository will greately improve your development speed.    
