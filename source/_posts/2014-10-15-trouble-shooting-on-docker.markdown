---
layout: post
title: "Trouble-Shooting on Docker"
date: 2014-10-15 19:07
comments: true
categories: docker
---
The guideline I follow is from :     
[https://wiki.archlinux.org/index.php/Docker](https://wiki.archlinux.org/index.php/Docker)    
### Working behind Proxy
When docker runs under the proxy, it will be blocked by the firewall, thus in the ArchLinux we have to kill the systemd started docker daemon, and manually set the proxy configuration for the docker daemon, following is the tips:    

```
$ systemctl stop docker.service
$ sudo HTTP_PROXY=http://1xx.*.*.2xx:2xx3 docker -d &

```
Then you run the docker for create the new machine  will be OK. 

### Default Configuration
That leads me for thinking the default configuration of ArchLinux , change it to :    

```
$ cat /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target docker.socket
Requires=docker.socket

[Service]
ExecStart=/usr/bin/docker -d 
LimitNOFILE=1048576
LimitNPROC=1048576

[Install]
Also=docker.socket

```
Add following line, but failed, Arch Wiki also indicates its failure:    

```
[Service]
Environment="http_proxy=192.168.1.1:3128"
ExecStart=
ExecStart=/usr/bin/docker -d -g /var/yourDockerDir

```
So everytime you want to enable proxy, simply manually reload it.    


Then reload the service status and restart the docker.service:   

```
sudo systemctl daemon-reload
sudo systemctl restart docker.service

```
Test the docker to view if it runs well:    

```
$ docker info

```
### Docker Management
List the installed images:    

```
[Trusty@~/code/octo/heroku/Tomcat]$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
archlinux           latest              a063a516f4c7        About an hour ago   293 MB
busybox             latest              e72ac664f4f0        13 days ago         2.433 MB
base/archlinux      2014.07.03          ea234cde99e6        12 weeks ago        282.9 MB
base/archlinux      2014.04.01          56c61f5c2920        12 weeks ago        293.3 MB
base/archlinux      latest              dce0559daa1b        12 weeks ago        282.9 MB

```
List Containers:    

```
[Trusty@~/code/octo/heroku/Tomcat]$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS                         PORTS               NAMES
50baf5783c6e        busybox:latest      "/bin/echo hello wor   6 minutes ago       Exited (0) 6 minutes ago                           mad_carson          
2f7108d2ee0e        archlinux:latest    "echo Success."        About an hour ago   Exited (0) About an hour ago                       jolly_galileo       

```
List the running Containers:    

```
[Trusty@~/code/octo/heroku/Tomcat]$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

```
Now start a container via(This command will run into the container and execute the /bin/bash):     

```
$ docker run -i -t archlinux /bin/bash
[root@b6ab14b2ce65 /]# 

```
Check the container status:    

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
b6ab14b2ce65        archlinux:latest    "/bin/bash"         27 seconds ago      Up 25 seconds                           high_wright   

```
When you exit, then the ps won't display the corresponding items.    

### Install More Images
Install via:    

```
$ docker run ubuntu /bin/echo hello world
$ docker run centos /bin/echo hello world

```
Run it ubuntu:    

```
$ docker run -i -t ubuntu /bin/bash   
root@34b68719493b:/# cat /etc/issue
Ubuntu 14.04.1 LTS \n \l

```
Run into centos:    

```
$ docker run -i -t centos /bin/bash   
bash-4.2# uname -a
Linux e3ec1911331b 3.16.4-1-ARCH #1 SMP PREEMPT Mon Oct 6 08:22:27 CEST 2014 x86_64 x86_64 x86_64 GNU/Linux
bash-4.2# cat /etc/issue
\S
Kernel \r on an \m

bash-4.2# which yum
/usr/bin/yum

```
