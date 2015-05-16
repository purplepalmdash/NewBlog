---
layout: post
title: "Trying Docker In Company"
date: 2015-01-26 01:14
comments: true
categories: linux
---
### Installation
Install docker via:    

```
$ sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
$ sh -c "echo deb http://get.docker.io/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"
$ apt-get update
$ apt-get install lxc-docker
$ which docker
/usr/bin/docker

```
### Very Beginning
Docker pull the docker.cn packages back, the speed is around 500K/

```
$ docker pull docker.cn/docker/ubuntu

```
Run into an instance:    

```
# docker run -i -t docker.cn/docker/ubuntu /bin/bash
root@3ad7689e600a:/# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 06:27 ?        00:00:00 /bin/bash
root        16     1  0 06:27 ?        00:00:00 ps -ef

```
In another terminal, show the running container:    

```
# docker ps
CONTAINER ID        IMAGE                           COMMAND             CREATED             STATUS              PORTS               NAMES
3ad7689e600a        docker.cn/docker/ubuntu:14.04   "/bin/bash"         11 seconds ago      Up 10 seconds                           sick_hodgkin 

```
### Make Changes And Submit
First made some modification to our container:    

```
sudo apt-get install vim

```
The above command will install vim.    
Now commit the changes:    

```
# docker commit c7ddc390f0c8 installed_vim_container
ed347fc03634e6c66ee45d213cf4d2839e55376f3e34d18c6e58bada1f701425

```
List all of the images:    

```
# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
installed_vim_container   latest              ed347fc03634        47 seconds ago      235.8 MB
docker.cn/docker/ubuntu   14.04               b39b81afc8ca        9 days ago          192.7 MB
docker.cn/docker/ubuntu   14.04.1             b39b81afc8ca        9 days ago          192.7 MB
docker.cn/docker/ubuntu   latest              b39b81afc8ca        9 days ago          192.7 MB
docker.cn/docker/ubuntu   trusty              b39b81afc8ca        9 days ago          192.7 MB

```
