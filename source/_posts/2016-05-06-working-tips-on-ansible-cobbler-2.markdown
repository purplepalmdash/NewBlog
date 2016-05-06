---
layout: post
title: "Working Tips on Ansible-cobbler(2)"
date: 2016-05-06 15:03:59 +0800
comments: true
categories: virtualization
---
### AIM
Change the vagrant box to libvirt, and let this libvirt machine working properly.    
### Image Transformation
Transform the image via following command:     

```
$ VBoxManage clonehd /home/dash/VirtualBox\ VMs/ansible-cobbler_cobbler-ubuntu_1462410925173_15793/packer-virtualbox-iso-1454031074-disk1.vmdk /home/dash/output.img --format raw && qemu-img convert -f raw /home/dash/output.img -O qcow2 /home/dash/ansible-cobbler.qcow2
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Clone medium created in format 'raw'. UUID: 6fbb99be-8004-43b5-831b-ec794a001c10
```

### Qemu Virtual Machine
Create a new machine, then configure the networking, edit the cobbler setting/dhcp setting, then `cobbler sync`, now the cobbler is adjusting to new environment.    

More detailed info could be seen in:    

[http://purplepalmdash.github.io/blog/2015/07/10/wh-worktips-9/](http://purplepalmdash.github.io/blog/2015/07/10/wh-worktips-9/)    
