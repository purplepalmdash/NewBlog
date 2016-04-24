---
layout: post
title: "在DevStack中使用Packer"
date: 2016-04-24 10:16:39 +0800
comments: true
categories: virtualization
---
### 导入源镜像
源镜像可以从ubuntu.com下载到，并使用以下命令导入:    

```
$ wget https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
$ glance image-create --name ubuntu-trusty --disk-format qcow2 \
--container-format bare --file trusty-server-cloudimg-amd64-disk1.img
```

### openstack.json文件
github上有现成的，克隆到本地:    

```
$ git clone https://github.com/Thingee/packer-devstack.git
```


