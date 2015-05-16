---
layout: post
title: "Play Docker(2)"
date: 2015-01-27 22:27
comments: true
categories: virtualization
---
Continue, but this time for further topics:    
### Export/Import
From [https://registry.hub.docker.com/](https://registry.hub.docker.com/) to find more interesting images:    
Use opensuse:    

```
$ sudo docker pull opensuse
$ sudo docker images
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
opensuse            latest              758c78b4040c        3 weeks ago         622.7 MB
opensuse            13.2                758c78b4040c        3 weeks ago         622.7 MB
opensuse            harlequin           758c78b4040c        3 weeks ago         622.7 MB
$ sudo docker run -i -t opensuse /bin/bash
:/ # yzpper in vim

```
After installed commit the changes and verify:    

```
$ sudo docker run -i -t install_vim_suse /bin/bash
:/ # which vim
/usr/bin/vim

```
Now we export it to tar file:    

```
$ sudo docker ps
$ sudo docker export 7b594d048b0b>~/opensuse_vim.tar
$ ls -l -h ~/opensuse_vim.tar
-rw-r--r--  1 Trusty root 704M Jan 27 22:39 opensuse_vim.tar

```
Made changes after we exported the tar file.    

```
$ sudo tar xvf opensuse_vim.tar
$ sudo touch ./root/I_Want_You_See_This_File
$ sudo rm -f opensuse_vim.tar
$ sudo tar cvf opensuse_vim_modified.tar ./*
$ ls -l -h *.tar
-rw-r--r-- 1 root root 704M Jan 27 22:45 opensuse_vim_modified.tar

```
Import the tar file into the images:    

```
$ sudo cat ./opensuse_vim_modified.tar | sudo docker import - Trusty/opensuse_vim_modified:v1.0
c18f7e43c4197a2a1a614a1ee91c6d8f0e06a6d7593ca94354303e3760e389a7
$ sudo docker images
$ sudo docker images
REPOSITORY                   TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
Trusty/opensuse_vim_modified   v1.0                c18f7e43c419        47 seconds ago      724 MB
$ sudo docker run -i -t Trusty/opensuse_vim_modified:v1.0 /bin/bash
:/ # ls /root/
I_Want_You_See_This_File  bin

```
Now we could see the modified files has been ported to our running containers.    
Even you could docker import from remote url:    

```
$sudo docker import http://example.com/exampleimage.tgz example/imagerepo

```
### Networking
#### Run app inside the container
First pull the images `training/webapp` back:    

```
$ sudo docker pull training/webapp
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
training/webapp     latest              31fa814ba25a        8 months ago        278.6 MB

```
Quickly enter the container and examine what's inside the pandora box:    

```
$ sudo docker run -i -t training/webapp /bin/bash
root@f19ca7c18763:/opt/webapp# cat /etc/issue
Ubuntu 12.04.4 LTS \n \l

root@f19ca7c18763:/opt/webapp# ls
Procfile  app.py  requirements.txt  tests.py
root@f19ca7c18763:/opt/webapp# cat app.py | more
import os

from flask import Flask

```
It's a flask based webapp.    
Manually run the app.py and use another terminal for testing it:    

```
root@f19ca7c18763:/opt/webapp# python app.py
 * Running on http://0.0.0.0:5000/
$ sudo docker exec -it f19ca7c18763 /bin/bash
root@f19ca7c18763:/opt/webapp# which curl
/usr/bin/curl
root@f19ca7c18763:/opt/webapp# curl http://127.0.0.1:5000
Hello world!root@f19ca7c18763:/opt/webapp# 

```
When you use curl, you will see in the first terminal it will indicates the request has been solved.    
Or you could directly request the page in host machine, via: `curl http://172.17.0.21:5000`, the result will be the same.    
#### Expose to World
Randomly let our container map to host's port via:    

```
$ sudo docker run -d -P --name web training/webapp python app.py
8781cf98cc685ae37a9aa421a9d30f71c64f12fa8fc07b2e1d888f761089e528
$ sudo docker ps -l
CONTAINER ID        IMAGE                    COMMAND             CREATED             STATUS              PORTS                     NAMES
8781cf98cc68        training/webapp:latest   "python app.py"     6 seconds ago       Up 5 seconds        0.0.0.0:49153->5000/tcp   web                 

```
Then on Internet, we could directly fetch the HelloWorld now.   

```
~% curl http://1xx.xxx.xx.xxx:49153
Hello world!%          

```
Inspect the name of the running container:    

```
$ sudo docker inspect -f "{{ .State.StartedAt }}" 8781cf98cc68
2015-01-28T04:25:38.768661692Z
$ sudo docker inspect -f "{{ .State.Pid }}" 8781cf98cc68
7307
$ sudo docker inspect -f "{{ .Name }}" 8781cf98cc68
/web

```
We got the name, then we could directly read the logs using this name:    

```
$ sudo docker logs -f web
 * Running on http://0.0.0.0:5000/
183.62.15.118 - - [28/Jan/2015 04:27:30] "GET / HTTP/1.1" 200 -
183.62.15.118 - - [28/Jan/2015 06:00:18] "GET / HTTP/1.1" 200 -
183.62.15.118 - - [28/Jan/2015 06:00:24] "GET / HTTP/1.1" 200 -

```
Using `-p` for specify the host port and container port mapping:    

```
$ sudo docker run -d -p 5000:5000 --name web1 training/webapp python app.py
2a0692015ba776f7daa957906470178df1fd8d26439422cd4528d2e253bf3331
$ sudo docker ps
CONTAINER ID        IMAGE                    COMMAND             CREATED             STATUS              PORTS                    NAMES
2a0692015ba7        training/webapp:latest   "python app.py"     3 seconds ago       Up 3 seconds        0.0.0.0:5000->5000/tcp   web1 

```
The test could be curl the 5000 port of the remote machine, while the logs could be found using `-f web1`.    
Examine the port mapping using following command:    

```
$ sudo docker run -d -P --name web3 training/webapp python app.py
$ sudo docker port web3 5000
0.0.0.0:49154

```
`-p` could be added as multiple ports, like:    

```
$ sudo docker run -d -p 5000:5000 -p 3000:80 training/webapp python app.py

```
### Docker Container Linking
Pull back a new images and run it as daemon:    

```
$ sudo docker run -d --name db training/postgres
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
training/postgres   latest              258105bea10d        7 months ago        364.5 MB
training/webapp     latest              31fa814ba25a        8 months ago        278.6 MB
$ sudo docker ps 
CONTAINER ID        IMAGE                      COMMAND                CREATED             STATUS              PORTS                     NAMES
ff6603d47552        training/postgres:latest   "su postgres -c '/us   14 seconds ago      Up 14 seconds       5432/tcp                  db                  
f94368f3d091        training/webapp:latest     "python app.py"        9 minutes ago       Up 9 minutes        0.0.0.0:49154->5000/tcp   web3                

```
Remove the existing web3 container, and create a new one which links to container `db`:    

```
$ sudo docker rm -f f94368f3d091
f94368f3d091
$ sudo docker run -d -P --name web4 --link db:db training/webapp python app.py
0cf8f0adcb3d1728c61e33c0c9184213478a2a231ba525339a3049534f4ce4ef
$ sudo docker ps
CONTAINER ID        IMAGE                      COMMAND                CREATED             STATUS              PORTS                     NAMES
0cf8f0adcb3d        training/webapp:latest     "python app.py"        4 seconds ago       Up 3 seconds        0.0.0.0:49155->5000/tcp   web4                
ff6603d47552        training/postgres:latest   "su postgres -c '/us   2 minutes ago       Up 2 minutes        5432/tcp                  db  

```
Examine the link infos when entering the container itself:    

```
$ sudo docker exec -i -t 0cf8f0adcb3d  /bin/bash
root@0cf8f0adcb3d:/opt/webapp# env
HOSTNAME=0cf8f0adcb3d
DB_NAME=/web4/db
DB_PORT_5432_TCP_ADDR=172.17.0.26
DB_PORT=tcp://172.17.0.26:5432
DB_PORT_5432_TCP=tcp://172.17.0.26:5432
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/opt/webapp
DB_PORT_5432_TCP_PORT=5432
SHLVL=1
HOME=/
DB_PORT_5432_TCP_PROTO=tcp
DB_ENV_PG_VERSION=9.3
_=/usr/bin/env


```
Use `ip address show` to examine the ip address.    
Why they could be linked?    
Also when you enter the web machine, cat its /etc/hosts, will see the db named:    

```
root@0cf8f0adcb3d:/opt/webapp# cat /etc/hosts
172.17.0.27	0cf8f0adcb3d
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.26	db

```
### Advance Networking
Secret of DNS/hostname/hosts:    

```
root@0cf8f0adcb3d:/opt/webapp# mount
/dev/vda1 on /etc/resolv.conf type ext4 (rw,relatime,data=ordered)
/dev/vda1 on /etc/hostname type ext4 (rw,relatime,data=ordered)
/dev/vda1 on /etc/hosts type ext4 (rw,relatime,data=ordered)

```
Once the variables changes the container's corresponding name will also be changed.    

#### Iptables
Container Visit WAN:    
Use sysctl's `ip_forward`, check it via:    

```
$ cat /proc//sys/net/ipv4/ip_forward
1

```
1 means that we could forward our traffic flow from WAN to 

WAN visit Container:     

```
$ sudo docker run -d -p 5000:5000 --name web5 training/webapp python app.py
$ sudo iptables -t nat -nL
......
Chain DOCKER (2 references)
target     prot opt source               destination         
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:49155 to:172.17.0.27:5000
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:5000 to:172.17.0.28:5000

```
The last one is added via our run command.    

