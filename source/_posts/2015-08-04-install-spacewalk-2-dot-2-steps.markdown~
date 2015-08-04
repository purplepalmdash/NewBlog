---
layout: post
title: "Install SpaceWalk 2.2 Steps"
date: 2015-08-04 09:18:15 +0800
comments: true
categories: Virtualizaiton
---
### Network Configuration
Make sure the following configuration in CentOS6:    

```
# cat /etc/hosts
10.9.10.10      spacewalk
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# cat /etc/sysconfig/network
NETWORKING=yes
NETWORKING_IPV6=no
HOSTNAME=localhost.localdomain
# cat /etc/hostname
spacewalk
```
Examine the result via:   

```
[root@spacewalk ~]# hostname
spacewalk
[root@spacewalk ~]# hostname --fqdn
spacewalk
```

### Packages Installation
First you should only have the following repo definition in the `/etc/yum.repos.d/`:    

```
# wget -O /etc/yum.repos.d/CentOS-Base.repo \
http://mirrors.aliyun.com/repo/Centos-6.repo 
# wget -O /etc/yum.repos.d/epel.repo \ 
http://mirrors.aliyun.com/repo/epel-6.repo
# ls /etc/yum.repos.d/
CentOS-Base.repo  epel.repo
```
Install following package(For preparing the installation of the old SpaceWalk version):     

```
# yum install -y jabberpy python-debian perl-Cache-Cache  jabberd python-hwdata net-snmp-perl perl-XML-LibXML perl-libxml-perl perl-Config-IniFiles perl-Net-IPv4Addr dojo perl-libxml-perl net-snmp-perl perl-Apache-Session perl-Apache-DBI  perl-Crypt-GeneratePassword perl-HTML-Table perl-XML-Generator perl-Net-SNMP perl-HTML-TableExtract perl-libapreq2
```

Now remove the epel.repo, add the following repo definition:    

```
# rpm -Uvh http://yum.spacewalkproject.org/2.2/RHEL/6/x86_64/spacewalk-repo-2.2-1.el6.noarch.rpm
# vim /etc/yum.repos.d/jpackage.repo
[jpackage-generic]
name=JPackage generic
#baseurl=http://mirrors.dotsrc.org/pub/jpackage/5.0/generic/free/
mirrorlist=http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0
enabled=1
gpgcheck=1
gpgkey=http://www.jpackage.org/jpackage.asc
```
Install spacewalk via:    

```
# yum install -y spacewalk-postgresql spacewalk-setup-postgresql spacecmd spacewalk-utils 
```
Use a pre-defined answer.txt for deployment:    

```
# vim /root/answer.txt
admin-email = root@localhost
ssl-set-org = Spacewalk Org
ssl-set-org-unit = spacewalk
ssl-set-city = My City
ssl-set-state = My State
ssl-set-country = US
ssl-password = spacewalk
ssl-set-email = root@localhost
ssl-config-sslvhost = Y
db-backend=postgresql
db-name=spaceschema
db-user=spacewalk
db-password=spacewalk
db-host=localhost
db-port=5432
enable-tftp=N
# spacewalk-setup --disconnected --answer-file=/root/answer.txt
```
You may encounter following error,     

```
*** Progress: ##
Could not install database.
# cat /var/log/rhn/install_db.log 
Initializing database: [  OK  ]
Starting postgresql service: [  OK  ]
createdb: database creation failed: ERROR:  encoding UTF8 does not match locale en_GB
DETAIL:  The chosen LC_CTYPE setting requires encoding LATIN1.
```
Solve it via:    

```
# sudo su postgres
bash-4.1$ psql
could not change directory to "/root"
psql (8.4.20)
Type "help" for help.

postgres=# UPDATE pg_database SET datallowconn = TRUE WHERE datname = 'template0';
UPDATE 1
postgres=# UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';
UPDATE 1
postgres=# drop database template1;
DROP DATABASE
postgres=# CREATE DATABASE template1 ENCODING = 'utf8' TEMPLATE = template0 LC_CTYPE ='en_US.utf8' LC_COLLATE = 'en_US.utf8';
CREATE DATABASE
postgres=# UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';
UPDATE 1
postgres=# UPDATE pg_database SET datallowconn = FALSE WHERE datname = 'template0';
UPDATE 1
postgres=# \q
bash-4.1$ exit
exit
```
Run `spacewalk-setup` again, this time you will pass the installation.      
Visit `http://YourIPAddress` for setting the login name and password:     

![/images/2015_08_04_10_54_48_879x600.jpg](/images/2015_08_04_10_54_48_879x600.jpg)   

Prepare the distro trees for CentOS7.    

```
# mkdir /var/distro-trees/centos7_64 -p
# chmod 755 /var/
# chmod 755 /var/distro-trees/
# chmod 755 /var/distro-trees/centos7_64/
# cp -ar /mnt1/* /var/distro-trees/centos7_64/
```

Create Channel:    

```
# /usr/bin/spacewalk-common-channels -v -u Username -p Password \ 
-a x86_64 -k unlimited  'centos7*'
```
Create Repository:    

```
#  spacecmd  -u Username -p Password -- distribution_create -n centos7 -p  /var/distro-trees/centos7_64/ -b centos7-x86_64 -t rhel_7
```
Now you could use the backend for creating the kickstart, via ` System-> KickStart-> Profile`     

### Channel Package Upload
Uploading packages to the channel could consume lots of time, CentOS7 DVD have more
than 8000 packages, thus takes around half a day for uploading.   

```
# wget https://127.0.0.1/pub/RHN-ORG-TRUSTED-SSL-CERT -O \
/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --no-check-certificate 
# find . -name "*rpm" | xargs rhnpush --channel=centos7-x86_64 --server=http://localhost/APP -v --tolerant -u Username -p Passwd
```

