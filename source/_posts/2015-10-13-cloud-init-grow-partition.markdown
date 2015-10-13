---
layout: post
title: "Cloud-Init Grow Partition"
date: 2015-10-13 14:37:57 +0800
comments: true
categories: Virtualization
---
### Resize QCOW2
Resize qcow2 file via:    

```
$ qemu-img info my_vm.img
image: my_vm.img
file format: qcow2
virtual size: 2.2G (2361393152 bytes)
disk size: 904M
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
$ qemu-img resize my_vm.img +100G
Image resized.
$ qemu-img info my_vm.img
image: my_vm.img
file format: qcow2
virtual size: 102G (109735575552 bytes)
disk size: 904M
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
```

### Enlarge Partition
Modify the meta-data, and enable the partition grow options in user-data:    

```
$ vim my-user-data
#cloud-config
+ growpart:
+   mode: auto
password: xxxxxxxx
chpasswd: { expire: False }
ssh_pwauth: True

ssh_authorized_keys:
 - ssh-rsa xxxxxxxxxxx
timezone: Asia/Chongqing

$ cat my-meta-data 
instance-id: d59656d7-b365-4940-ae95-9168c32c68b7
$ echo "instance-id: $(uuidgen || echo i-abcdefg)" > my-meta-data
$ cat my-meta-data 
instance-id: 5cad0dc4-facb-4079-b045-fbbc05caaf4a
```

Regenerate the image:    

```
$ rm -f my-seed.img
$ cloud-localds my-seed.img my-user-data my-meta-data
```
Restart the vm then you could get the disk resized.    
