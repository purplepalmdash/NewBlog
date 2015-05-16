---
layout: post
title: "Deploy Local Service Using Juju"
date: 2015-03-23 09:11
comments: true
categories: Virtualization
---
Since the OpenContrail deploy is using local deployment, that means, directly deploy to local machine. But the lab lack of the environment of the local ubuntu based machine, so I want to deploy a service to local first, then transform the whole project from local deployment to MAAS deployment.   
In a Ubuntu14.04 machine, do following steps.    

```
$ sudo add-apt-repository ppa:juju/stable 
$ sudo vim /etc/apt/source.list
# This is for juju
deb http://ppa.launchpad.net/juju/stable/ubuntu trusty main 
deb-src http://ppa.launchpad.net/juju/stable/ubuntu trusty main 
$ sudo apt-get install juju juju-core juju-local juju-quickstart
$ sudo apt-get install charm-tools
$ sudo apt-get install uvtool-libvirt uvtool

```
Configure the juju for using local:     

```
$ git clone https://github.com/juju/plugins.git ~/.juju-plugins
$ vim ~/.zshrc
# Add juju_plugins to global path
PATH=$PATH:$HOME/.juju-plugin
$ source ~/.zshrc
$ juju init
$ vim ~/.juju/environments.yaml
local:
 type: local

 # <Commented Section>

 # The default series to deploy the state-server and charms on.
 #
 default-series: precise
 #
 ## ** add these lines to support KVM and LXC deployment **
 lxc-use-clone: true
 container: kvm

```
Start the machine via:   

```
$ juju bootstrap --debug

```
Add the machines via:    

```
[Trusty@~]$  juju set-constraints mem=512M
[Trusty@~]$  juju add-machine --constraints "root-disk=16G mem=1G"
created machine 1
[Trusty@~]$ juju status
environment: local
machines:
  "0":
    agent-state: started
    agent-version: 1.21.3.1
    dns-name: localhost
    instance-id: localhost
    series: trusty
    state-server-member-status: has-vote
  "1":
    instance-id: pending
    series: precise
services: {}

```
After a long wait, it will boot a machine which have 1G and 1 Core, and let it running.     

