---
layout: post
title: "Tips On Cloud-Init"
date: 2015-10-12 10:50:53 +0800
comments: true
categories: Virtualization
---
### 参考
主要参考了    
[http://huang-wei.github.io/programming/2013/12/23/run-cloud-init-in-local-kvm.html](http://huang-wei.github.io/programming/2013/12/23/run-cloud-init-in-local-kvm.html)    

这里主要记录的是操作步骤。    

### 介绍
红帽介绍:     
 Cloud-Init 是一个用来自动配置虚拟机的初始设置（如主机名，网卡和密钥）的工具。它可以在
使用模板部署虚拟机时使用，从而达到避免网络冲突的目的。     
在使用这个工具前，cloud-init 软件包必须在虚拟机上被安装。安装后，Cloud-Init 服务会在系
统启动时搜索如何配置系统的信息。您可以使用只运行一次窗口来提供只需要配置一次的设置信息
；或在 新建虚拟机、编辑虚拟机和编辑模板窗口中输入虚拟机每次启动都需要的配置信息。     

### cloud-init安装
Ubuntu 14.04上可以通过以下命令来安装cloud-init:     

```
$ apt-cache search cloud-utils
cloud-utils - metapackage for installation of upstream cloud-utils source
$ sudo apt-get install cloud-utils
```

### 镜像准备
在[http://cloud-images.ubuntu.com/releases/](http://cloud-images.ubuntu.com/releases/)
可以找到Ubuntu制作的ubuntu cloud image, image分版本, 这里使用14.04的image。    

```
$ wget http://cloud-images.ubuntu.com/releases/14.04.3/
release-20151008/ubuntu-14.04-server-cloudimg-amd64-disk1.img
```

取回来后的镜像可以直接使用，但解压开后读取速度会更快:    

```
$ qemu-img convert -O qcow2 ubuntu-14.04-server-cloudimg-amd64-disk1.img my_vm.img
```

对比两个镜像大小可以看到:    

```
$ qemu-img info ubuntu-14.04-server-cloudimg-amd64-disk1.img 
image: ubuntu-14.04-server-cloudimg-amd64-disk1.img
file format: qcow2
virtual size: 2.2G (2361393152 bytes)
disk size: 246M
cluster_size: 65536
Format specific information:
    compat: 0.10
$ qemu-img info my_vm.img 
image: my_vm.img
file format: qcow2
virtual size: 2.2G (2361393152 bytes)
disk size: 903M
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
```

### 配置脚本内容
my-user-data内容:    

```
$ cat my-user-data
#cloud-config
password: xxxxxx
chpasswd: { expire: False }
ssh_pwauth: True

ssh_authorized_keys:
 - ssh-rsa xxxxxx

timezone: Asia/Chongqing
```

通过my-user-data生成img文件:    

```
$ cloud-localds my-seed.img my-user-data
```

由之前的my_vm.img和my-seed.img文件启动虚拟机:    

```
$ qemu-system-x86_64 -net nic -net user,hostfwd=tcp::2222-:22 -hda my_vm.img -hdb my-seed.img -m 512
```

通过qemu的窗口或者ssh登录系统: `ssh -p 2222 ubuntu@localhost`.    

### 引入meta-data
meta-data的内容与虚拟机的实例相关，只用来做初始化，虚拟机实例运行完一次以后就不需要修改
。但如果要引入更新，则重建一下instance-id即可。    

更新my-meta-data文件内容:   

```
$ echo "instance-id: $(uuidgen || echo i-abcdefg)" > my-meta-data
```

由my-meta-data和my-user-data生成my-seed.img文件:    

```
$ cloud-localds my-seed.img my-user-data my-meta-data
```

启动虚拟机:    

```
$ qemu-system-x86_64 -net nic -net user,hostfwd=tcp::2222-:22 -hda my_vm.img -hdb my-seed.img -m 512
$ kvm -net nic -net user,hostfwd=tcp::2222-:22 -hda my_vm.img -hdb my-seed.img -m 512
```

### 其他初始化行为
需要初始化的脚本:   

```
$ cat hello_world.sh 
#!/bin/bash
echo "hello world!" >> /home/ubuntu/test
```

将初始化脚本和cloud config data合并:    

```
$ write-mime-multipart
--output=combined-userdata.txt hello_world.sh:text/x-shellscript my-user-data
```

由生成的combined-userdata.txt生成my-seed.img:    

```
$ echo "instance-id: $(uuidgen || echo i-abcdefg)" > my-meta-data
$ cloud-localds my-seed.img combined-userdata.txt my-meta-data
```

重启后即可得到更新后的系统镜像.    
