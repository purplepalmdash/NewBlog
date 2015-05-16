---
layout: post
title: "Trouble Shooting On Juju's Local Deployment"
date: 2015-04-28 12:11
comments: true
categories: Virtualization
---
When deploying juju, after `juju bootstrap`, use juju ssh for login, it will hint me:    

```
$ juju ssh 1
......
Permission denied (publickey).

```
That could be solved by specify the id_rsa.pub key:     

```
$ ssh-keygen -t rsa -b 2048
$ juju bootstrap
$ juju bootstrap
$ juju deploy wordpress
$ juju deploy mysql
$ juju add-relation wordpress mysql
$ juju status
$ juju expose wordpress

```
By doing this you could make your juju deployment on local successfully.   
