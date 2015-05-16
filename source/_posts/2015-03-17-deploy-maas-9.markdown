---
layout: post
title: "Deploy MAAS(9)"
date: 2015-03-17 17:44
comments: true
categories: Virtualization
---
### Use Local Charms
Retrieve the charms via:    

```
$ sudo apt-get install charm-tools
$ cat autocharms.sh
juju charm get nova-cloud-controller /home/Trusty/charms/trusty
juju charm get keystone /home/Trusty/charms/trusty
juju charm get glance  /home/Trusty/charms/trusty
juju charm get cinder /home/Trusty/charms/trusty
juju charm get rabbitmq-server /home/Trusty/charms/trusty
juju charm get openstack-Trustyboard /home/Trusty/charms/trusty
juju charm get nova-compute /home/Trusty/charms/trusty
# juju charm get nova-compute /home/Trusty/charms/trusty
$ du -hs /home/Trusty/charms/trusty/*
1.5M    /home/Trusty/charms/trusty/cinder
1.6M    /home/Trusty/charms/trusty/glance
1.7M    /home/Trusty/charms/trusty/keystone
824K    /home/Trusty/charms/trusty/mysql
1.9M    /home/Trusty/charms/trusty/nova-cloud-controller
1.6M    /home/Trusty/charms/trusty/nova-compute
1.2M    /home/Trusty/charms/trusty/openstack-Trustyboard
1.2M    /home/Trusty/charms/trusty/rabbitmq-server

```
Deploy via:    

```
juju deploy --to lxc:1 --repository=/home/Trusty/charms/ local:trusty/mysql
juju deploy --to lxc:1 --repository=/home/Trusty/charms/ local:trusty/keystone
juju deploy --to lxc:1 --repository=/home/Trusty/charms/ local:trusty/nova-cloud-controller
juju deploy --to lxc:1 --repository=/home/Trusty/charms/ local:trusty/glance
juju deploy --to lxc:1 --repository=/home/Trusty/charms/ local:trusty/rabbitmq-server
juju deploy --to lxc:1 --repository=/home/Trusty/charms/ local:trusty/openstack-Trustyboard
juju deploy --to lxc:1 --repository=/home/Trusty/charms/ local:trusty/cinder 

```
### Backup
Backup the existing environment via:    

```
$ juju backup create --filename backupOpenStack.tgz
$ ls -l *.tgz
-rw-r--r-- 1 Trusty Trusty  25595066 Mar 17 17:23 juju-backup-20150317-1723.tgz

```
The store method will be covered later.    
