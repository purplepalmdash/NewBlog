---
layout: post
title: "MAAS Deploy(5)"
date: 2015-03-16 14:15
comments: true
categories: Virtualization
---
### Local Repository
Sometimes when I run bootstrap, the procedure will failed, that's because the Fucking GFW somethines will blocking some critical packet flow. Thus I have to setup the local repository.   
Refers to:    
[https://jujucharms.com/docs/howto-privatecloud](https://jujucharms.com/docs/howto-privatecloud)   

Use `juju --debug sync-tools` we could sync the tools for local usage.    

Use local tools for bootstrap is:    
First generate the tools under the specified directory:    

```
juju metadata generate-tools -d ~/.juju/metadata

```
Then use it via:    

```
juju bootstrap --metadata-source ~/.juju/metadata --upload-tools -v --show-log

```
To add an constraint to bootstrap on large memory system:     

```
$ juju bootstrap --metadata-source ~/.juju/metadata --upload-tools -v --show-log --constraints="mem=2G"

```
Now you will start a computer which have more than 2G Memory, verify it via:    

```
Trusty@MassTestingUbuntu1404:~$ juju status
environment: maas
machines:
  "0":
    agent-state: started
    agent-version: 1.21.3.1
    dns-name: 4GJujuNode.maas
    instance-id: /MAAS/api/1.0/nodes/node-f03c5290-cbb6-11e4-b7bd-5254002e6eef/
    series: trusty
    hardware: arch=amd64 cpu-cores=2 mem=3072M tags=virtual
    state-server-member-status: has-vote
services: {}

```
Next we will deploy on more nodes.   
### Trouble-Shooting On Maas
Install on ubuntu14.04 it will failed when configuring the postgresql.   
Should its configuration have some problems?     

First I use the ppa repository, but I noticed that in the previous successful installation, my installation is not start from ppa, but from official, so this time, from official.   

The problem is because the postgresql is not configured properly, so doing following steps for installing the correct configuration of the postgresql:    

```
$ sudo locale-gen en_US en_US.UTF-8 zh_CN zh_CN.UTF-8
$ sudo dpkg-reconfigure locales
$ sudo pg_createcluster 9.3 main --start
$ sudo apt-get install maas
$ sudo apt-get install maas-dhcp maas-dns

```   
Now you could install more newer version of the maas and etc.    
