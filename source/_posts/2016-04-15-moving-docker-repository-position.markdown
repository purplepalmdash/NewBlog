---
layout: post
title: "Moving Docker Repository Position"
date: 2016-04-15 15:55:15 +0800
comments: true
categories: 
---
Since the root partition is not so large, I have to change the default position of the
docker repository, following are the steps:    

### Make a Soft Link
Make a soft link to the docker repository via:    

```
$ sudo mkdir DockerRepo
$ sudo chown -R dash:dash DockerRepo
$ sudo chmod  777 -R DockerRepo
$ sudo tar -zcC /var/lib docker > /home/juju/DockerRepo/var_lib_docker-backup-$(date +%s).tar.gz
$ ls -l -h /home/juju/DockerRepo
$ sudo mv /var/lib/docker /home/juju/DockerRepo/
$ sudo ln -s /home/juju/DockerRepo/docker /var/lib/docker
$ sudo service docker restart
$ sudo service docker status
```
### Change Docker Parameters

```
Ubuntu/Debian: edit your /etc/default/docker file with the -g option: DOCKER_OPTS="-dns 8.8.8.8 -dns 8.8.4.4 -g /mnt"
```
