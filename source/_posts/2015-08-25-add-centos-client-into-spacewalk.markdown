---
layout: post
title: "Add CentOS Client into SpaceWalk"
date: 2015-08-25 14:30:44 +0800
comments: true
categories: Linux
---
### Installation
Take i386 architecture for example, first download the rpm package then install it:    

```
$ wget /yum.spacewalkproject.org/2.3-client/RHEL/6/i386/spacewalk-client-repo-2.3-2.el6.noarch.rpm
$ rpm -ivh spacewalk-client-repo-2.3-2.el6.noarch.rpm 
```
If your architecture is x86_64, then select x86_64 corresponding rpm and install it.   

Enable EPEL:    

```
# BASEARCH=$(uname -i)
# rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
```
Now install the spacewalk client via:    

```
# yum install -y rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin
```

### Configuration
Install Spacewalk server's CA certificate on the server to enable SSL communication:    

```
# wget http://10.11.11.3/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
# rpm -ivh rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
```
Add following item into the `/etc/hosts` and test its reachable:    

```
# vim /etc/hosts
....
10.11.11.3      spacewalk
# ping spacewalk
PING spacewalk (10.11.11.3) 56(84) bytes of data.
64 bytes from spacewalk (10.11.11.3): icmp_seq=1 ttl=64 time=0.214 ms
...
```
Now register your machine into the server:    

```
#  rhnreg_ks --serverUrl=https://spacewalk/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-centos6-i386
```

Verify it in SpaceWalk's system details view.   

### Enable osad 
Install and configure it via:    

```
# yum install osad
# vim /etc/sysconfig/rhn/osad.conf
osa_ssl_cert = /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
# yum install python-hashlib
# service osad start
```
After osad has been installed, the installation of packages will be done almost
instantly.    
