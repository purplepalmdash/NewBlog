---
layout: post
title: "Setup Vagrant-libvirt Env On Ubuntu15.04"
date: 2016-03-23 20:49:52 +0800
comments: true
categories: virtualization
---
For continue working at home, I have to install vagrant-libvirt on
Ubuntu15.04, following are steps:    

### Vagrant Installation
The vagrant version in repository is too old, examine it via:    

```
$ apt-cache policy vagrant
vagrant:
  Installed: (none)
  Candidate: 1.6.5+dfsg1-2
  Version table:
     1.6.5+dfsg1-2 0
        500 http://mirrors.aliyun.com/ubuntu/ vivid/universe amd64 Packages
```
Download the installation file in:      
[https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb](https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb)    

Install it via:    

```
$ sudo dpkg -i vagrant_1.8.1_x86_64.deb
$ which vagrant
/usr/bin/vagrant
```

### Vagrant-libvirt
For building vagrant-libvirt, we have to install following packages:     

```
$ sudo apt-get install libvirt-bin libvirt-dev qemu-kvm ruby-dev
$ sudo adduser YourName libvirtd

```

Installing vagrant plugins:    

```
$ sudo mkdir /var/lib/gems
$ sudo chmod 777 -R /var/lib/gems/
$ gem source -r https://rubygems.org/
$ gem source -a http://mirrors.aliyun.com/rubygems/
$ gem source
$ gem install json -v '1.8.3'
$ gem install ruby-libvirt -v '0.6.0'
$ vagrant plugin install vagrant-libvirt
$ vagrant plugin install vagrant-mutate
$ vagrant plugin install --plugin-version 0.0.3 fog-libvirt
```

