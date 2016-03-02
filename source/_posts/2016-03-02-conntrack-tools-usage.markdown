---
layout: post
title: "conntrack-tools usage"
date: 2016-03-02 17:30:31 +0800
comments: true
categories: linux
---
### 参考
[https://blogs.it.ox.ac.uk/networks/2014/09/30/linux-and-eduroam-nat-logging-perl-and-regular-expressions/](https://blogs.it.ox.ac.uk/networks/2014/09/30/linux-and-eduroam-nat-logging-perl-and-regular-expressions/)    
### 安装
ArchLinux下:    

```
$ sudo pacman -S conntrack-tools
```

### 使用
记录新建/销毁连接数至文件:    

```
$ sudo touch /var/log/conntrack-data.log
$ sudo chmod 777 /var/log/conntrack-data.log
$ sudo conntrack -E -eNEW,DESTROY --src-nat -otimestamp,extended --buffer-size=104857600 > /var/log/conntrack-data.log
```
