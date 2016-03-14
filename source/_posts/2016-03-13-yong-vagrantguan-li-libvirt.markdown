---
layout: post
title: "用Vagrant管理libvirt"
date: 2016-03-13 16:07:59 +0800
comments: true
categories: virtualization
---
### 先决条件
Vagrant为0.8.1.     

参考:    
[http://linuxsimba.com/vagrant.html](http://linuxsimba.com/vagrant.html)    
[http://linuxsimba.com/vagrant-libvirt-install/](http://linuxsimba.com/vagrant-libvirt-install/)     

### Ubuntu设置
考虑到天朝防火墙的存在,需要经过以下命令才能安装vagrant-libvirt插件:    


```
$ sudo apt-get install -y libvirt-dev ruby-dev
$ gem source -r https://rubygems.org/
$ gem source -a http://mirrors.aliyun.com/rubygems/
$ gem install ruby-libvirt -v '0.6.0'
$ gem install vagrant-libvirt -v '0.0.32'
$ vagrant plugin install vagrant-libvirt
$ vagrant plugin list
vagrant-libvirt (0.0.32)
$ axel http://linuxsimba.com/vagrantbox/ubuntu-trusty.box
$ vagrant box add ./ubuntu-trusty.box --name "trusty64"
```

### ArchLinux设置
按照ArchLinux wiki的方法,安装vagrant-libvirt插件:    

```
 # in case it's already installled
 vagrant plugin uninstall vagrant-libvirt
 
 # vagrant's copy of curl prevents the proper installation of ruby-libvirt
 sudo mv /opt/vagrant/embedded/lib/libcurl.so{,.backup}
 sudo mv /opt/vagrant/embedded/lib/libcurl.so.4{,.backup}
 sudo mv /opt/vagrant/embedded/lib/libcurl.so.4.4.0{,.backup}
 sudo mv /opt/vagrant/embedded/lib/pkgconfig/libcurl.pc{,.backup}
 
 CONFIGURE_ARGS="with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib" vagrant plugin install vagrant-libvirt
 
 # https://github.com/pradels/vagrant-libvirt/issues/541
 export PATH=/opt/vagrant/embedded/bin:$PATH
 export GEM_HOME=~/.vagrant.d/gems
 export GEM_PATH=$GEM_HOME:/opt/vagrant/embedded/gems
 gem uninstall ruby-libvirt
 gem install ruby-libvirt
 
 # put vagrant's copy of curl back
 sudo mv /opt/vagrant/embedded/lib/libcurl.so{.backup,}
 sudo mv /opt/vagrant/embedded/lib/libcurl.so.4{.backup,}
 sudo mv /opt/vagrant/embedded/lib/libcurl.so.4.4.0{.backup,}
 sudo mv /opt/vagrant/embedded/lib/pkgconfig/libcurl.pc{.backup,}
```

### 检查安装的box
可以通过以下命令检查已经安装好的box:    

```
$ vagrant box list
trusty64 	(libvirt, 0)
ubuntu1404	(virtualbox, 0)
```
### 启动虚拟机

