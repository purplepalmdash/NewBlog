---
layout: post
title: "Deploy MAAS(8)"
date: 2015-03-17 14:27
comments: true
categories: Virtualization
---
This part is for deploying OpenStack using Juju and let it run in single node.    
### Environment Preparation
2 virtual machines created using virt-manager, each of them has 2 core, 3Gigabyte Memory, around 60G Disk space.     
### Deploy
The most of the nodes are deployed in container.    

```
$ juju deploy --to 0 juju-gui
$ juju deploy --to lxc:0 mysql
$ juju deploy --to lxc:0 keystone
$ juju deploy --to lxc:0 nova-cloud-controller
$ juju deploy --to lxc:0 glance
$ juju deploy --to lxc:0 rabbitmq-server
$ juju deploy --to lxc:0 openstack-Trustyboard
$ juju deploy --to lxc:0 cinder 

```
The compute node is deployed in a machine which enable the nested virtualization.    

```
$ juju deploy nova-compute

```
Add each other's relationship:    

```
$ juju add-relation mysql keystone
$ juju add-relation nova-cloud-controller mysql
$ juju add-relation nova-cloud-controller rabbitmq-server
$ juju add-relation nova-cloud-controller glance
$ juju add-relation nova-cloud-controller keystone
$ juju add-relation nova-compute nova-cloud-controller
$ juju add-relation nova-compute mysql
$ juju add-relation nova-compute rabbitmq-server:amqp
$ juju add-relation nova-compute glance
$ juju add-relation glance mysql
$ juju add-relation glance keystone
$ juju add-relation glance cinder
$ juju add-relation mysql cinder
$ juju add-relation cinder rabbitmq-server
$ juju add-relation cinder nova-cloud-controller
$ juju add-relation cinder keystone
$ juju add-relation openstack-Trustyboard keystone

```
Then change the password of keystone via:    

```
$ juju set keystone admin-password="helloworld"

```
Detect the ipaddress of the openstack-Trustyboards via:    

```
$ juju status openstack-Trustyboard
$ http://ip_address_of_Trustyboard/horizon

```
The final result is listed like:    
![/images/2015_03_17_14_35_25_1037x646.jpg](/images/2015_03_17_14_35_25_1037x646.jpg)    
