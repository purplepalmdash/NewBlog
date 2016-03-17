---
layout: post
title: "Vagrant-libvirt Playing"
date: 2016-03-16 10:31:53 +0800
comments: true
categories: virtualization
---
最终目的是用vagrant实现CloudStack+Xenserver的自动化部署。    

### CentOS6.7 box Creating
用packer生成CentOS6.7 amd64的镜像，这个镜像默认是virtualbox兼容的，用vagrant-mutate插件
将其转换为libvirt可用的box镜像:     

```
# vagrant mutate centos-6.7.virtualbox.box libvirt
# cd /root/.vagrant.d/boxes
# ls
centos-6.7.virtualbox  trusty64
# mv centos-6.7.virtualbox/ centos6764
# vagrant box list
centos6764 (libvirt, 0)
trusty64   (libvirt, 0)
```

创建Vagrantfile文件启动一个实验性质的虚拟机：     

```
# pwd
/media/opensusue/dash/Code/Vagrant/CentOS2New
# ls
Vagrantfile  Vagrantfile~
# cat Vagrantfile
    # -*- mode: ruby -*-
    # vi: set ft=ruby :
    Vagrant.configure(2) do |config|
      # The most common configuration options are documented and commented below.
      # For a complete reference, please see the online documentation at
      # https://docs.vagrantup.com.
    
      config.vm.box = "centos6764"
      # vagrant issues #1673..fixes hang with configure_networks
      config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
      config.vm.provider :libvirt do |domain|
        domain.memory = 512
        domain.nested = true
      end
    
      config.vm.define :centosnew do |centosnew|
        centosnew.vm.network :private_network, :ip => "192.168.88.2"
      end
    
    end
# vagrant up
```
`vagrant up`以后，一个名为`CentOS2New_centosnew`的虚拟机将被创建， 命名规则为当前文件夹
名+定义的vm名称。   

虚拟机启动完毕后，检查状态并登录到该机器:     

```
# vagrant status
Current machine states:

centosnew                 running (libvirt)

The Libvirt domain is running. To stop this machine, you can run
`vagrant halt`. To destroy the machine, you can run `vagrant destroy`.
# vagrant ssh centosnew
Last login: Wed Mar 16 02:31:18 2016 from 192.168.121.1
[vagrant@localhost ~]$
``` 

我们可以检查网卡状态，是否设置为我们需要设置的地址`192.168.88.2`.   

### 更多定制化参数
#### 嵌套虚拟化
未知原因，我在CentOS6上检查嵌套虚拟化总是提示有问题，所以以下的验证是在Ubuntu系统上验证
的。    

我们在上面的配置文件里制定了nested选项为true, 现在登录进去检查一下嵌套虚拟化是否加载成
功:    

```
vagrant@vagrant:~$ lsmod | grep kvm
kvm_intel             143590  0 
kvm                   452043  1 kvm_intel
vagrant@vagrant:~$ modinfo kvm_intel | grep nested
parm:           nested:bool
vagrant@vagrant:~$ cat /sys/module/kvm_intel/parameters/nested
N
vagrant@vagrant:~$ sudo modprobe -r kvm_intel
vagrant@vagrant:~$ sudo modprobe kvm_intel nested=1
vagrant@vagrant:~$ cat /sys/module/kvm_intel/parameters/nested
Y
```

改变nested选项为false后，验证步骤如下:    

```
$ cat /sys/module/kvm_intel/parameters/nested
N
``` 
值得注意的是，在虚拟机中，仍然可以通过`modprobe kvm_intel nested=1`来打开nested选项。    

#### CPU Passthrough
指定参数为`domain.cpu_mode = 'host-passthrough'`:     

```
  config.vm.provider :libvirt do |domain|
    domain.memory = 512
    domain.nested = false
    #domain.cpu_mode = 'host-passthrough'
  end
```

未指定时:      

```
vagrant@vagrant:~$ cat /proc/cpuinfo  | grep -i "model name"
model name	: Intel Core i7 9xx (Nehalem Class Core i7)
```
指定后:    

```
[vagrant@localhost ~]$ cat /proc/cpuinfo | grep -i "model name"
model name	: Intel(R) Core(TM) i3 CPU         540  @ 3.07GHz
```
#### 指定hostname
安装cloudstack时hostname是必要条件之一， Vagrantfile中可以指定vm的hostname:     

```
  config.vm.define "centosnew" do |centosnew|
    centosnew.vm.hostname = "centosnew.example.com"
  end
```
启动虚拟机后可以通过`hostname`和`hostname --fqdn`来检查结果。   

### 快照
通过sahara来实现libvirt机器的快照:    

```
$ vagrant plugin install sahara
```
在验证系统时，可以进入vagrant的sandbox模式，验证成功后才正式提交。    

