---
layout: post
title: "Create Vagrant For JD"
date: 2014-12-19 09:55
comments: true
categories: web
---
### Purpose
For deploying the development environment in the Vagrant based environment, choose ubuntu 14.04.    
### Create
List the exising Vagrants:    

```
$ vagrant box list
panamax-coreos-box-494.4.0 (virtualbox, 0)

```
Now download the vbox file of 14.04 daily Cloud image i386 from [www.vagrantbox.es](www.vagrantbox.es):     

```
$ wget https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box

```
Though this method could starts the vbox, but it's not clean, it will have problems in our deliveris.  So use the result from [https://atlas.hashicorp.com/boxes/search](https://atlas.hashicorp.com/boxes/search)     

```
$ vagrant init  ubuntu/trusty32
$ vagrant up

```
Current we use 32, because we may have windowsxp users, or 32-bit system users.   

After installation, list all of the installed vboxes:    

```
$ vagrant box list
panamax-coreos-box-494.4.0 (virtualbox, 0)
ubuntu/trusty32            (virtualbox, 14.04)

```
### Configuration
The Bootstrap.sh is listed as following:     

``` sh
#!/usr/bin/env bash
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password rootpass'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password rootpass'
apt-get update
apt-get install -y meld
apt-get install -y nginx mysql-server mysql-server-5.5
apt-get install -y nodejs libc-ares2 libv8-3.14.5
apt-get install -y fossil
apt-get install -y git
apt-get install -y php5 php5-fpm
apt-get install -y php5-mysql
apt-get install -y php-pear
apt-get install -y install-info
apt-get install -y php5-dev
apt-get install -y npm
npm install -g pdf.js

```
then write the Vagrantfile list like:    

```
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty32"
  config.vm.network "private_network", ip: "192.168.50.50"
  config.proxy.http = "http://1xx.x.xx.xxx:xxxx"
  config.proxy.https = "http://1xx.x.xx.xxx:xxxx"
  config.proxy.no_proxy = "localhost"
  config.vm.provision :shell, path: "bootstrap.sh"
end

```
Now run `vagrant provision` then we could refresh the installation.    
