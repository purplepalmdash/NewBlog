---
layout: post
title: "搭建基于docker的监控系统"
date: 2016-06-20 09:39:55 +0800
comments: true
categories: Linux
---
### Graphite/Grafana
这两个用于记录和展示监控数据，通过以下命令可以快速搭建:     

#### Graphite
开启容器:     

```
$ mkdir -p /local/path/to/graphite/storage/whisper/
$ sudo docker run -d \
  --name graphite \
  -p 8080:80 \
  -p 2003:2003 \
  -v /local/path/to/.htpasswd:/etc/nginx/.htpasswd \
  -v /local/path/to/graphite/storage/whisper:/opt/graphite/storage/whisper \
  sitespeedio/graphite
```
创建htpasswd文件的方法可以参阅:      
[http://httpd.apache.org/docs/2.2/programs/htpasswd.html](http://httpd.apache.org/docs/2.2/programs/htpasswd.html)     

当然如果你使用默认的密码的话，用户名/密码是:guest/guest.     
#### Grafana
开启容器:     

```
# mkdir -p /local/path/to/grafana
# docker run -d -p 3000:3000 --name=grafana -v /local/path/to/grafana:/var/lib/grafana  grafana/grafana
``` 
默认用户名/密码为admin/admin.     

### Collectd
用于采集节点机上的数据，

```
# docker run -d --net=host --privileged -v /:/hostfs:ro --name=collectd -e \
HOST_NAME=localhost -e \
GRAPHITE_HOST=192.168.1.79 andreasjansson/collectd-write-graphite
```

参数说明:     

```
--net=host : 	使用主机上的网络配置
GRAPHITE_HOST:  前面设置的graphite机器的地址
```

### systemd 启动方式
collectd启动方式:    

```
$ sudo vim /usr/lib/systemd/system/collectddocker.service
[Unit]
Description=collectd container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a collectd
ExecStop=/usr/bin/docker stop -t 2 collectd

[Install]
WantedBy=multi-user.target
```
启动并使能服务:    

```
$ sudo systemctl enable collectddocker.service
```

