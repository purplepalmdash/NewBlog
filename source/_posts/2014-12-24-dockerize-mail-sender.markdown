---
layout: post
title: "Dockerize Mail Sender"
date: 2014-12-24 10:57
comments: true
categories: web
---
In DigitalOcean VPS, which runs the Ubuntu 14.04.1 LTS, setup a mail sender server.     
### Installation
Install the docker.io via:    

```
# apt-get install docker.io

```
Git clone the repository from the github, configure it and build the container:     

```
# pwd
/root/code/docker_mail
# git clone https://github.com/lava/dockermail.git
# ls
 dockermail
# cd dockermail
# cat mail-base/domains 
*******.com.cn
# cat mail-base/passwords 
catch-all@xxxxx.com.cn:{PLAIN}password123
admin@xxxxxx.com.cn:{SHA256-CRYPT}$5$3qaCC/fV65Adtfoy$O20EXoSOcgWKf5NyAZnXAtGPQoSgeYRjLm56M25.H12
# make

```
Run the containers:     

```
root@lilimarleen:~/code/docker_mail/dockermail# make run-all
docker run -d -p 0.0.0.0:25:25 -p 0.0.0.0:587:587 -p 0.0.0.0:143:143 -v /srv/vmail:/srv/vmail dovecot:2.1.7
4dac1e99be85100d7847fb46976249196b0a970ad4f630136cced4ccdc11ac27
docker run -d -p 127.0.0.1:33100:80 rainloop:1.6.9
e7246bcf39ddee334c45ca41c268eb5ebdc092d069024ff81b70f16a3ab11cb4
docker run -d -p 127.0.0.1:33200:80 -v /srv/owncloud:/var/www/owncloud/data owncloud:7.0.2 
9e62a4f6140cf43caeb5dc096f995649d3a898ffdeb439a7a7c4501c527f3672
root@lilimarleen:~/code/docker_mail/dockermail# docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                                            NAMES
9e62a4f6140c        owncloud:7.0.2      /bin/sh -c 'cp -npr    3 seconds ago       Up 2 seconds        127.0.0.1:33200->80/tcp                                          backstabbing_sinoussi   
e7246bcf39dd        rainloop:1.6.9      /bin/sh -c 'apachect   3 seconds ago       Up 3 seconds        127.0.0.1:33100->80/tcp                                          sad_sinoussi            
4dac1e99be85        dovecot:2.1.7       /bin/sh -c 'chown -R   3 seconds ago       Up 3 seconds        0.0.0.0:25->25/tcp, 0.0.0.0:143->143/tcp, 0.0.0.0:587->587/tcp   evil_ptolemy      

```
### nsenter
Use nsenter for entering the running container:     

```
# Ubuntu 14.04 don't have nsenter - the straight forward way required me to install build tools and etc.
# I preferred to keep the system clean and install nsenter in a container and then copy the command to the host
# Note - its also possible to run nsenter from a container (didn't tried) https://github.com/jpetazzo/nsenter

# start a container
docker run --name nsenter -it ubuntu:14.04 bash

## in the docker
apt-get update
apt-get install git build-essential libncurses5-dev libslang2-dev gettext zlib1g-dev libselinux1-dev debhelper lsb-release pkg-config po-debconf autoconf automake autopoint libtool

git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git util-linux
cd util-linux/

./autogen.sh
./configure --without-python --disable-all-programs --enable-nsenter
make

## from different shell - on the host
docker cp nsenter:/util-linux/nsenter /usr/local/bin/
docker cp nsenter:/util-linux/bash-completion/nsenter /etc/bash_completion.d/nsenter

```
Thus you have the nsenter.    
### Enter the container    
Get the PID via:    

```
# docker inspect --format "{{.State.Pid}}" a66adc0e63fc
24740

```
Enter the docker container and view the status:     

```
# nsenter --target 24740 --mount --uts --ipc --net --pid -- /bin/bash
root@a66adc0e63fc:/# 

```
Why we want to enter this terminal? Because we want to view the password of the admin. The configuration file says:    

```
# cat mail-base/passwords 
admin@xxxx.com.cn:{SHA256-CRYPT}$5$3qaCC/fV65Adtfoy$O20EXoSOcgWKf5NyAZnXAtGPQoSgeYRjLm56M25.H12

```
If you met "port has been occupied", you should do like following:     
Remove all of the containers:    

```
# docker ps -a | grep "ago" |  awk '{print $1}' |  xargs --no-run-if-empty docker rm

```

### Trouble Shooting
First you should add corresponding MX record in you domainname service provider.    





