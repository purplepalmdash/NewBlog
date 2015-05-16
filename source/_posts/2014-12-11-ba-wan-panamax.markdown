---
layout: post
title: "把玩Panamax"
date: 2014-12-11 14:14
comments: true
categories: Virtualization
---
### 前提条件
在MAC上把玩Panamax前，需要安装Virtualbox, Vagrant, 而后, 用下列命令安装Panamax:    

```
$ brew install http://download.panamax.io/installer/brew/panamax.rb
$ panamax init

```
这将开始下载CoreOS镜像，需要等一段时间。    

In fact the panamax could also be installed on ArchLinux rather than only in Ubuntu, simply run:    

```
$ curl http://download.panamax.io/installer/ubuntu.sh | bash

```
### Trouble Shooting
#### Init failed    


```
$ panamix init
A different VM with name panamax-vm has been created already. Please re-install or delete panamax-vm VM and try again.

```
Use following command for listing all of the virtualmachines:    

```
VBoxManage list vms

```
Didn't found the panamax related infos.    
Finally solve the problem via:     

```
[Trusty@~/.vagrant.d]$ pwd
/home/Trusty/.vagrant.d
[Trusty@~/.vagrant.d]$ mv plugins.json plugins.json.back
[Trusty@~/.vagrant.d]$ mv gems gems.back

```
#### Frozen String
The error code:     

```
/opt/vagrant/embedded/gems/gems/vagrant-1.7.0/lib/vagrant/util/subprocess.rb:28:in `encode!': can't modify frozen String (RuntimeError)

```
Is it because I upgraded to the latest vagrant?    

I couldnot roll back to vagrant1.6, so I upgraded to the vagrant-git, its version is 1.7.1, from the yaourt repository, thus I could get the installation continue.   


### OpenSuse Way
First remove the installed virtualbox:     

```
$ zypper remove virtualbox
$ zypper in libvncserver0 LibVNCServer-devel

```
Install the 4.3 version of virtualbox:    

```
$ wget http://download.opensuse.org/repositories/home:/Warhammer40k:/stuff/openSUSE_13.1/x86_64/VirtualBox-custom-4.3-4.3.20-1.1.x86_64.rpm
$ rpm -ivh VirtualBox-custom-4.3-4.3.20-1.1.x86_64.rpm

```
Now doing the same as we noticed above.     
But the `panamax init` got following error messages:    

```
==> panamax-vm: Clearing any previously set network interfaces...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "create"]

Stderr: 0%...
Progress state: NS_ERROR_FAILURE
VBoxManage: error: Failed to create the host-only adapter
VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterface, interface IHostNetworkInterface
VBoxManage: error: Context: "int handleCreate(HandlerArg*, int, int*)" at line 66 of file VBoxManageHostonly.cpp

```
