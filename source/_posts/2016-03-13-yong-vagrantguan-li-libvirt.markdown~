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
### 导入box
用packer编译出来的box文件默认工作在virtualbox下,我们需要用一个插件将其转换为
libvirt可用的box:    

```
#  vagrant plugin install vagrant-mutate
# vagrant mutate ubuntu-14.04.virtualbox.box libvirt
Extracting box file to a temporary directory.
Converting ubuntu-14.04.virtualbox from virtualbox to libvirt.
    (100.00/100%)
Cleaning up temporary files.
The box ubuntu-14.04.virtualbox (libvirt) is now ready to use.
# cd /root/.vagrant.d/boxes/
# mv ubuntu-14.04.virtualbox/ trusty64
# vagrant box list
trusty64 (libvirt, 0)
```

### 检查安装的box
可以通过以下命令检查已经安装好的box:    

```
$ vagrant box list
trusty64 	(libvirt, 0)
ubuntu1404	(virtualbox, 0)
```

### 配置Vagrantfile
以下是一个例子:    

```
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|

  config.vm.box = "trusty64"
  # vagrant issues #1673..fixes hang with configure_networks
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.vm.provider :libvirt do |domain|
    domain.memory = 256
    domain.nested = true
  end

# Private network using virtual network switching
  config.vm.define :vm1 do |vm1|
    vm1.vm.network :private_network, :ip => "192.168.56.11"
  end

  config.vm.define :vm2 do |vm2|
    vm2.vm.network :private_network, :ip => "192.168.56.12"
  end

  # Private network. Point to Point between 2 Guest OS using a TCP tunnel
  # Guest 1
  #config.vm.define :test_vm1 do |test_vm1|
  #  test_vm1.vm.network :private_network,
  #    :libvirt__tunnel_type => 'server',
  #    # default is 127.0.0.1 if omitted
  #    # :libvirt__tunnel_ip => '127.0.0.1',
  #    :libvirt__tunnel_port => '11111'

  # Guest 2
  #config.vm.define :test_vm2 do |test_vm2|
  #  test_vm2.vm.network :private_network,
  #    :libvirt__tunnel_type => 'client',
  #    # default is 127.0.0.1 if omitted
  #    # :libvirt__tunnel_ip => '127.0.0.1',
  #    :libvirt__tunnel_port => '11111'


  # Public Network
  config.vm.define :vm1 do |vm1|
    vm1.vm.network :public_network,
      :dev => "virbr0",
      :mode => "bridge",
      :type => "bridge"
  end
end

```

### 启动虚拟机

```
# vagrant up --provider=libvirt
```

启动时会出现以下问题, 解决方案为:    


```
$ vagrant up --provider=libvirt
....
Missing required arguments: libvirt_uri
.....
$ vagrant plugin install --plugin-version 0.0.3 fog-libvirt
```
