---
layout: post
title: "Deploy MAAS(6)"
date: 2015-03-16 17:43
comments: true
categories: Virtualization
---
### More Nodes
I imported 2 3-G mem size nodes. 2 Nodes were created manually.    
First we should set the constraint via:   

```
$ juju bootstrap --metadata-source ~/.juju/metadata --upload-tools -v --show-log --constraints="mem=3G"

```     
Then we can verify and imported these machines via:   

```
$ juju get-constraints
$ juju add-machine
$ juju status
$ juju deploy --to 1 mysql

```
### Deploy OpenStack
In first node, do following:   

```
$ juju deploy --to 0 juju-gui
$ juju deploy --to lxc:0 mysql && juju deploy --to lxc:0 keystone && juju deploy --to lxc:0 nova-cloud-controller && juju deploy --to lxc:0 glance && juju deploy --to lxc:0 rabbitmq-server && juju deploy --to lxc:0 openstack-Trustyboard && juju deploy --to lxc:0 cinder

```
Then deploy the nova-compute node via:    

```
$ juju deploy nova-compute

```

