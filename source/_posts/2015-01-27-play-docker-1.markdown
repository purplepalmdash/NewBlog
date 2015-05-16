---
layout: post
title: "Play Docker(1)"
date: 2015-01-27 20:39
comments: true
categories: virtualization
---
For playing docker and prepare for my presentation, I wrote this series and try to record my tips on playing docker.    
### Background
I created a droplet on DigitalOcean.com, which is running CentOS 7, the memory is only 512M, with one core and 20G size disk, which means its caculation resource is pretty limited, so heavy tasks should be avoid, like building.    
Since the memory is only 512M, I allocated 1G swapfile to the machine.    
The usable disk is 17G now.    
### Docker Installation
Docker is already part of CentOS7, so install it directly via:    

```
$ sudo yum install -y docker
$ which docker
/usr/bin/docker

```
Start the service and make it default:    

```
$ sudo service docker start
Redirecting to /bin/systemctl start  docker.service
$ sudo chkconfig docker on
Note: Forwarding request to 'systemctl enable docker.service'.
ln -s '/usr/lib/systemd/system/docker.service' '/etc/systemd/system/multi-user.target.wants/docker.service'

```
Now even if you restart the machine, the service would be automatically started together with system boot.   
### First Instance
Pull the debian back:    

```
$ sudo docker pull debian
Pulling repository debian
c90d655b99b2: Download complete 
511136ea3c5a: Download complete 
30d39e59ffe2: Download complete 
Status: Downloaded newer image for debian:latest
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
debian              wheezy              c90d655b99b2        8 hours ago         85.12 MB
debian              7                   c90d655b99b2        8 hours ago         85.12 MB
debian              7.8                 c90d655b99b2        8 hours ago         85.12 MB
debian              latest              c90d655b99b2        8 hours ago         85.12 MB

```
Install the `lsb_release`, then run different tags, all of them are the same:    

```
$ sudo docker run -i -t debian:7.8 /bin/bash
xxxxxxx # lsb_release -a 
No LSB modules are available.
Distributor ID:	Debian
Description:	Debian GNU/Linux 7.8 (wheezy)
Release:	7.8
Codename:	wheezy

```
### Destroy Container
List all of the container via ` sudo docker ps -a`, then destroy the container via `sudo docker rm xxxxxx` while xxxxxx is the container ID.    
Play magic, one line for remove all of the containers:    

```
$ sudo docker rm `sudo docker ps -a -q`
16d606046c24
65ceffcf4a7b
dfbc6d0fa051
1dd18dbf8b9c
66c931879c2c
$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

```
### Remove The Images
One line for remove all of the ununsed images:    

```
$ sudo docker images -q
c90d655b99b2
c90d655b99b2
c90d655b99b2
c90d655b99b2
$ sudo docker rmi `sudo docker images -q`
Untagged: debian:7
Untagged: debian:7.8
Untagged: debian:latest
Untagged: debian:wheezy
Deleted: c90d655b99b2ec5b7e94d38c87f92dce015c17a313caeaae0e980d9b9bed8444
Deleted: 30d39e59ffe287f29a41a3f8bd70734afc8728329e3289945cbdc5bbf07cd980
Deleted: 511136ea3c5a64f264b78b5433614aec563103b4d4702f3ba7d4d2698e22c158
Error response from daemon: No such image: c90d655b99b2
Error response from daemon: No such image: c90d655b99b2
Error response from daemon: No such image: c90d655b99b2
2015/01/27 21:14:01 Error: failed to remove one or more images
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE

```
But it would be add a pipe like `sudo docker images -q | uniq`    
### Connect To Existing Running Container
#### Docker 1.3 Ways
From Docker 1.3, we could use `docker exec -it` for attaching to running container:    

```
$ sudo docker run -i -t centos /bin/bash
[root@1f9005d495c6 /]# 
$ sudo docker ps
[sudo] password for Trusty: 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
1f9005d495c6        centos:7            "/bin/bash"         8 minutes ago       Up 8 minutes                            sick_jones          
$ sudo docker exec -it 1f9005d495c6 /bin/bash
[root@1f9005d495c6 /]# 

```
But the Container's lifecycle is controlled by the first instance, `docker exec` only attached to, this means if you exit the container, all of the `docker exec` tty will be shutdown.    
#### Nsenter Ways
First use `docker inspect` for get the PID.    

```
$ sudo docker ps 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
8337ea52cfd1        centos:7            "/bin/bash"         4 seconds ago       Up 4 seconds                            pensive_blackwell   
$ PID=$(sudo docker inspect --format {{.State.Pid}} 8337ea52cfd1)
$ echo $PID
3951

```
Use nsenter for enter the PID's namespace:    

```
$ sudo nsenter --target $PID --mount --uts --ipc --net --pid
[root@8337ea52cfd1 /]#

```
#### Lazy Wrap of Nsenter Ways
Just visit:     
[https://github.com/jpetazzo/nsenter](https://github.com/jpetazzo/nsenter), download the docker-enter, and place it in the right place:    

```
$ sudo docker ps 
[sudo] password for Trusty: 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
8337ea52cfd1        centos:7            "/bin/bash"         11 minutes ago      Up 11 minutes                           pensive_blackwell   
$ sudo docker-enter pensive_blackwell ls -la
...
$ sudo docker-enter 8337ea52cfd1 /bin/bash
[root@8337ea52cfd1 /]# 

```
#### Docker Attach
If you attach to the container, you must remember, better you use tmux holding the whole instance.      

```
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
057435c2f1cb        centos:7            "/bin/bash"         5 seconds ago       Up 4 seconds                            evil_kirch          
$ sudo docker attach 057435c2f1cb
[root@057435c2f1cb /]# ls
bin  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  selinux  srv  sys  tmp  usr  var

```
Once you quit from the "attached" tty, the origin tty will also quit.    

### More System Info
Use `docker info` to get more detailed system infos:    

```
$ sudo docker info
Containers: 3
Images: 3
Storage Driver: devicemapper
 Pool Name: docker-253:1-397799-pool
 Pool Blocksize: 65.54 kB
 Data file: /var/lib/docker/devicemapper/devicemapper/data
 Metadata file: /var/lib/docker/devicemapper/devicemapper/metadata
 Data Space Used: 563.1 MB
 Data Space Total: 107.4 GB
 Metadata Space Used: 1.069 MB
 Metadata Space Total: 2.147 GB
 Library Version: 1.02.84-RHEL7 (2014-03-26)
Execution Driver: native-0.2
Kernel Version: 3.10.0-123.8.1.el7.x86_64
Operating System: CentOS Linux 7 (Core)
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
centos              7                   8efe422e6104        3 weeks ago         224 MB
centos              centos7             8efe422e6104        3 weeks ago         224 MB
centos              latest              8efe422e6104        3 weeks ago         224 MB
$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                       PORTS               NAMES
057435c2f1cb        centos:7            "/bin/bash"         3 minutes ago       Exited (0) 54 seconds ago                        evil_kirch          
8337ea52cfd1        centos:7            "/bin/bash"         21 minutes ago      Exited (127) 4 minutes ago                       pensive_blackwell   
1f9005d495c6        centos:7            "/bin/bash"         34 minutes ago      Exited (0) 24 minutes ago                        sick_jones          

```
### Commit Changes
Install the vim in the running container:    

```
$ sudo docker run -i -t centos /bin/bash
[sudo] password for Trusty: 
[root@ea29113ba0e1 /]# which vim
/usr/bin/which: no vim in (/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin)
[root@ea29113ba0e1 /]# yum install -y vim

```
In another container, commit the changes:    

```
$ sudo docker commit ea29113ba0e1 vim_installed
54cebb627e37600e81a832616eb3253af5dd26d0d248b9a9251e23bc8c93567d
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
vim_installed       latest              54cebb627e37        12 seconds ago      362.6 MB
centos              latest              8efe422e6104        3 weeks ago         224 MB
centos              7                   8efe422e6104        3 weeks ago         224 MB
centos              centos7             8efe422e6104        3 weeks ago         224 MB

```
Next time if you want to use the vim installed images, simply run:     

```
$ sudo docker run -it vim_installed /bin/bash
[root@4b76f0c7bc46 /]# which vim
/usr/bin/vim

```
### Job Controlling
Use environment variables for recording the running job:    

```
$ JOB=$(sudo docker run -d vim_installed /bin/sh -c "while true; do echo Hello World; sleep 1; done")
$ echo $JOB
5dcb0884d27077e84ef4fea7fc0b3e8151657e92e0c2d4d1e33f84483715dfb9

```
Examine the log from the app's output:    

```
$ sudo docker logs $JOB
$ sudo docker logs --follow $JOB

```
Add --follow will continue to view the log output.    
Stop the running container:    

```
$ sudo docker stop $JOB
5dcb0884d27077e84ef4fea7fc0b3e8151657e92e0c2d4d1e33f84483715dfb9

```
Start the stopped container:   

```
$ sudo docker start $JOB
5dcb0884d27077e84ef4fea7fc0b3e8151657e92e0c2d4d1e33f84483715dfb9

```
Or Restart:    

```
$ sudo docker restart $JOB

```
Or kill:   

```
$ sudo docker kill $JOB

```
Notice the kill exit code is -1:    

```
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
$ sudo docker ps -a
CONTAINER ID        IMAGE                  COMMAND                CREATED             STATUS                        PORTS               NAMES
5dcb0884d270        vim_installed:latest   "/bin/sh -c 'while t   9 minutes ago       Exited (-1) 8 seconds ago                         focused_pike 

```
`sudo docker rm $JOB` will remove the job.    
