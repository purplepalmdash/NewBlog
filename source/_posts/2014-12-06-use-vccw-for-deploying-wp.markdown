---
layout: post
title: "Use VCCW For Deploying WP"
date: 2014-12-06 12:13
comments: true
categories: web
---
For deploying differenet versions of Wordpress, I searched various kinds of solutions, includeing docker and vagrant, finally I found VCCW(A Wordpress development environment) is what I want, because I could freely changes the WP versions, so following is the guideline for installing and configurating the whole virtualmachine.    
### Install
The installation steps are listed as:    

```
$ vagrant plugin install vagrant-hostsupdater
$ wget https://github.com/miya0001/vccw/archive/1.9.1.tar.gz
$ tar xzvf 1.9.1.tar.gz
$ cd vccw-1.9.1
$ vagrant up

```
This will start downloading and configrating the VM, it will cost sometimes. So just drink a coffee and get back.    


```
$ vagrant plugin install vagrant-omnibus && vagrant plugin install vagrant-hostsupdater &&  vagrant plugin install vagrant-proxyconf

```
Configure proxy and chef?     

```
$ vim Vagrantfile
Vagrant.configure(2) do |config|
  config.proxy.http     = "http://1xx.xx.xx:xxx:2xxx"
  config.proxy.https    = "http://1xx.xx.xx:xxx:2xxx"
  config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"

config.omnibus.chef_version = :latest
$ VAGRANT_APT_HTTP_PROXY="http://1xx.xx.xx.xxx:2xxxx vagrant up
$ VAGRANT_APT_HTTP_PROXY="http://1xx.xx.xx.xxx:2xxxx vagrant provision

```


```
vagrant halt

```




