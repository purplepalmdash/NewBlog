---
layout: post
title: "LXCize the KVM machine"
date: 2015-05-25 11:46:28 +0800
comments: true
categories: virtualization
---
In order to make exsiting kvm based machine to be lxc container, following is the steps.      

### Convert Disk Formats
First we want to convert the qcow2 format image to raw format, by following command:     

```
$ qemu-img convert u12-debug-ui.qcow2 Contrail.raw
```
This will take a very long time, because qcow2 file will expand to a whole images, like mine, the Contrail.raw in fact expands to 100G size.   


### LXC the KVM 
Since we have the raw image file, we could create a new configuration file for starting the machine:     


```
 myvm.conf
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0
lxc.network.ipv4 = xxx.xxx.10.230/24
lxc.network.ipv4.gateway = xxx.xxx.0.176
#lxc.network.link = lxcbr0
lxc.utsname = myvminlxc

lxc.tty = 4
lxc.pts = 1024
lxc.rootfs = /dev/mapper/loop0p1
lxc.arch = amd64
lxc.cap.drop = sys_module mac_admin

lxc.cgroup.devices.deny = a
# Allow any mknod (but not using the node)
lxc.cgroup.devices.allow = c *:* m
lxc.cgroup.devices.allow = b *:* m
# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm
# consoles
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
#lxc.cgroup.devices.allow = c 4:0 rwm
#lxc.cgroup.devices.allow = c 4:1 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm
# rtc
lxc.cgroup.devices.allow = c 254:0 rwm
#fuse
lxc.cgroup.devices.allow = c 10:229 rwm
#tun
lxc.cgroup.devices.allow = c 10:200 rwm
#full
lxc.cgroup.devices.allow = c 1:7 rwm
#hpet
lxc.cgroup.devices.allow = c 10:228 rwm
#kvm
lxc.cgroup.devices.allow = c 10:232 rwm
```

Now setup the image file via, this will use the `/dev/mapper/loop0p1` as the root partition:      

```
$ sudo kpartx -a Contrail.img
```

Now start the machine via:    
```
$ sudo lxc-start -n myvminlxc -f ./myvm.conf
```

Your machine will boot into the lxc, and its behavior is the same as the kvm based machine. 


### TroubleShooting
The root could not login into the lxc, because of the selinux enabled in the Ubuntu Host, simply disable it in `/etc/selinux/config` by:    

```
$ sudo vim /etc/selinux/config
#SELINUX=permissive
SELINUX=disabled

```

