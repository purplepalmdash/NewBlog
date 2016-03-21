---
layout: post
title: "Use Vagrant To Manage XenServer"
date: 2016-03-21 14:20:09 +0800
comments: true
categories: Virtualization
---
### Building Templates
Build XenServer 6.2 Template is pretty easy, simply do following:      

```
$ git clone  https://github.com/imduffy15/packer-xenserver.git
$ cd packer-xenserver
$ packer build template.iso
```
After building, check the following box file available under the directory:     

```
$ ls -l -h XenServer.box 
-rw-rw-r-- 1 dash dash 708M  3月 21 14:41 XenServer.box
```
### Import box File
Import the generated box file via:    

```
$ vagrant box add XenServer.box --name "XenServer62"
$ vagrant box list | grep XenServer62
XenServer62        (virtualbox, 0)
```

### Start the Virtualbox XenServer

```
$ mkdir XenServer62
$ cd XenServer62 
$ vim Vagrantfile
Vagrant.configure(2) do |config|

    # disable mounting of vagrant folder as its not supported on xenserver
    config.vm.synced_folder ".", "/vagrant", disabled: true

    # disable checking for vbguest versions as its not supported on xenserver
    if Vagrant.has_plugin?("vagrant-vbguest")
      config.vbguest.auto_update = false
    end

    config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize [ "modifyvm", :id, "--nicpromisc2", "allow-all" ]
    end

    config.vm.define :csagent do |csagent|
      csagent.vm.box = "XenServer62"
    end

end
$ vagrant up
```

### XenServer In libvirt
We want to use XenServer under libvirt(kvm), thus we have to do following changes:    

First startup the virtualbox vagrant environment of XenServer, then login to the
localhost(127.0.0.1) as root:     

```
$ vagrant ssh csagent
[vagrant@localhost ~]$ ssh root@127.0.0.1
[root@localhost ~]# ifconfig | grep eth0 | grep HWaddr
eth0      Link encap:Ethernet  HWaddr 08:00:27:49:A4:92  
[root@localhost etc]# ifconfig -a | grep eth1
eth1      Link encap:Ethernet  HWaddr 08:00:27:9D:8C:71 
```

Get the Hardware Address(eth0/eth1) via ifconfig, we need them in the following
operations.   

Now remove the udev items of `eth0`, `eth1` in `/etc/udev/rules.d/60-net.rules`:     

```
# vi /etc/udev/rules.d/60-net.rules
    # Rules generated from static configuration and last boot data
    #SUBSYSTEM=="net" KERNEL=="eth*" SYSFS{address}=="08:00:27:49:a4:92" ID=="0000:00:03.0" NAME="eth0"
    #SUBSYSTEM=="net" KERNEL=="eth*" SYSFS{address}=="08:00:27:9d:8c:71" ID=="0000:00:08.0" NAME="eth1"
```

Remove the dynamic rules of the interface renaming:     

```
# vim /etc/sysconfig/network-scripts/interface-rename-data/dynamic-rules.json 
    # Automatically adjusted file.  Do not edit unless you are certain you know how to
    {
        "lastboot": [
            - [
            -     "08:00:27:49:a4:92",
            -     "0000:00:03.0",
            -     "eth0"
            - ],
            - [
            -     "08:00:27:9d:8c:71",
            -     "0000:00:08.0",
            -     "eth1"
            - ]
        ],
        "old": []
    }
```
Should looks like this:    

```
# cat /etc/sysconfig/network-scripts/interface-rename-data/dynamic-rules.json 
    # Automatically adjusted file.  Do not edit unless you are certain you know how to
    {
        "lastboot": [
        ], 
        "old": []
    }
```

Now add the static rules for the XenServer:     

```
$
08:00:27:9D:8C:71 
```

Get the Hardware Address(eth0/eth1) via ifconfig, we need them in the following
operations.   

Now remove the udev items of `eth0`, `eth1` in `/etc/udev/rules.d/60-net.rules`:     

```
# vi /etc/udev/rules.d/60-net.rules
    # Rules generated from static configuration and last boot data
    #SUBSYSTEM=="net" KERNEL=="eth*" SYSFS{address}=="08:00:27:49:a4:92" ID=="0000:00:03.0" NAME="eth0"
    #SUBSYSTEM=="net" KERNEL=="eth*" SYSFS{address}=="08:00:27:9d:8c:71" ID=="0000:00:08.0" NAME="eth1"
```

Remove the dynamic rules of the interface renaming:     

```
# vim /etc/sysconfig/network-scripts/interface-rename-data/dynamic-rules.json 
    # Automatically adjusted file.  Do not edit unless you are certain you know how to
    {
        "lastboot": [
            - [
            -     "08:00:27:49:a4:92",
            -     "0000:00:03.0",
            -     "eth0"
            - ],
            - [
            -     "08:00:27:9d:8c:71",
            -     "0000:00:08.0",
            -     "eth1"
            - ]
        ],
        "old": []
    }
```
Should looks like this:    

```
# vim  /etc/sysconfig/network-scripts/interface-rename-data/static-rules.conf 
eth0:mac = "08:00:27:49:A4:92"
eth1:mac = "08:00:27:9D:8C:71"
```
Define xenbr0 and eth0 bridging configuration:    

```
# vim /etc/sysconfig/network-scripts/ifcfg-xenbr0 
DEVICE=xenbr0
TYPE=Bridge
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp
# vim  /etc/sysconfig/network-scripts/ifcfg-eth0 
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=none
BRIDGE=xenbr0
```
Now shutdown the Virtualbox Based XenServer VM via:    

```
[root@localhost network-scripts]# shutdown -h now
```

### Package for Libvirt
Package the modified vbox file and export to libvirt via following steps:    

Verify the env is down:    

```
$ vagrant status
Current machine states:

csagent                   poweroff (virtualbox)
```

Package the modified vm:    

```
$ vagrant package
==> csagent: Clearing any previously set forwarded ports...
==> csagent: Exporting VM...
==> csagent: Compressing package to: /home/dash/Code/Vagrant/XenServer62/package.box
$ ls
package.box  Vagrantfile  Vagrantfile~
```
Mutate to libvirt box:    

```
$ vagrant mutate package.box libvirt
Extracting box file to a temporary directory.
Converting package from virtualbox to libvirt.
    (100.00/100%)
Cleaning up temporary files.
The box package (libvirt) is now ready to use.
$ cd ~/.vagrant.d/boxes 
$ vagrant box list
XenServer62        (virtualbox, 0)
XenServer62        (libvirt, 0)
```

### Start the libvirt XenServer
Edit the Vagrantfile like following:    

```
# vim Vagrantfile
Vagrant.configure(2) do |config|

  # vagrant issues #1673..fixes hang with configure_networks
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.ssh.username = 'vagrant'
  config.ssh.password = 'vagrant'
  config.ssh.insert_key = 'true'
  config.vm.provider :libvirt do |domain|
    domain.nic_model_type = 'e1000'
    domain.memory = 384
    domain.nested = true
    domain.cpu_mode = 'host-passthrough'
  end


  # csagent node.
  # Add one networking, modify hostname, define memory, CPU cores.
  config.vm.define :csagent do |csagent|
    csagent.vm.box = "XenServer62"
    csagent.vm.hostname = CLOUDSTACK_AGENT_HOSTNAME
    csagent.vm.network :private_network, :ip => CLOUDSTACK_AGENT_IP, :mac => "08:00:27:9D:8C:71"
    # Disable mounting of vagrant folder as it's not supported on xenserver
    csagent.vm.synced_folder ".", "/vagrant", disabled: true
    csagent.vm.provider :libvirt do |domain|
      domain.memory = 8192
      domain.cpus = 4
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
      domain.nic_model_type = 'e1000'
      domain.management_network_mac = "08:00:27:49:A4:92"
    end
  end

end
```
Start the Vagrant machine via: `vagrant up --provider=libvirt`.    

The result shows XenServer are now running under libvirt:    
![/images/2016_03_21_16_10_44_643x284.jpg](/images/2016_03_21_16_10_44_643x284.jpg)    
