---
layout: post
title: "Setup Squid"
date: 2015-08-21 11:33:13 +0800
comments: true
categories: Linux
---
### Installation And Configuration

```
# yum install -y squid
# vim /etc/squid/squid.conf
http_port 3072
#acl localnet src 192.168.0.0/16        # RFC1918 possible internal network
# Squid normally listens to port 3128
http_port 3072
cache_mem 64 MB
maximum_object_size 4 MB
# Cache 3GB
cache_dir ufs /home/juju/SquidCache     3072    16      256
access_log /var/log/squid/access.log
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic kspc-01 proxy
auth_param basic credentialsttl 2 hours
acl myacl proxy_auth REQUIRED
http_access allow myacl
http_access deny all
visible_hostname squid.kspc-01
```
First you should setup the cache file:    

```
# squid -z
# systemctl start suiqd
# systemctl enable squid
```
Change username password via:    

```
$ htpasswd -c /etc/squid/passwd user1
$ htpasswd  /etc/squid/passwd user2
$ htpasswd  /etc/squid/passwd user3
```

### Usage
In firefox: Edit->Preference->Network->Settings->, change proxy setting.   
