---
layout: post
title: "用Graphite呈现广州空气质量(4)"
date: 2015-12-16 16:29:43 +0800
comments: true
categories: Visualization
---
### Tessera
直接导入Graphite中定义好的dashboard即可，值得注意的是，如何创建模板，或者说，如何创建一
个template用于渲染我们导入的各个数据？    

导入的时候出现了如下的问题:    

![/images/2015_12_16_18_34_44_701x483.jpg](/images/2015_12_16_18_34_44_701x483.jpg)    

可见tessera中对数据的定制化是必须的。   

### Grafana
安装及配置为自动启动:   

```
$ wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.6.0_amd64.deb
$ sudo dpkg -i grafana_2.6.0_amd64.deb
$ sudo service grafana-server start
$ sudo update-rc.d grafana-server defaults 95 10
```
默认用户名/密码为 admin/admin.     

现在添加graphite数据源，例如：    

![/images/2015_12_16_19_20_33_703x484.jpg](/images/2015_12_16_19_20_33_703x484.jpg)    
