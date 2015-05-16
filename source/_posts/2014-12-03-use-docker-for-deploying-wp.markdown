---
layout: post
title: "Use Docker for deploying WP"
date: 2014-12-03 19:33
comments: true
categories: virtualization
---
Just for swiftly deploy WP and test the RESTful API, I did following operations and runs a WP temporately.    
### PULL
Pull following containers:    

```
$ docker pull mysql
$ docker pull wordpress
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
<none>              <none>              480ac552cd39        About an hour ago   192.8 MB
mysql               latest              98840bbb442c        39 hours ago        235.5 MB
wordpress           latest              9f51af77fd96        8 days ago          470.5 MB

```
### Configuration
Explanation for following commands, `--name` is the name for our container, `-p 8038:80` is mapping the host machine's 8038 port to container `wordpress_1`:    

```
$ docker run --name mysql_1 -e MYSQL_ROOT_PASSWORD=xxxx -d mysql
$ docker run --name wordpress_1 --link mysql_1:mysql -p 8038:80 -d wordpress

```
Now open your browser to `http://localhost:8038` and you got the wordpress installation window.   
### WP
After we installed WP, we could install JSON REST API from:    
[https://wordpress.org/plugins/json-rest-api/](https://wordpress.org/plugins/json-rest-api/)    
After installation, we could test the REST API via curl:    

```
TBD

```

### View Docker status
First we should grab the docker's PID via following command:    

```
$ docker  inspect  --format "{{ .State.Pid }}"  mysql_1 
28254
$ docker  inspect  --format "{{ .State.Pid }}"  wordpress_1
28754

```
Then we could nsenter the docker container and view its status:    

```
$ sudo nsenter --target 28254 --mount --uts --ipc --net --pid -- /bin/bash
$ sudo nsenter --target 28754 --mount --uts --ipc --net --pid -- /bin/bash

```
In the 'attached' environment we could inspect the status for corresponding services.   
### Stop docker contains
via `docker stop` we could simply stop the docker container:     

```
[Trusty@~/code/30days/Docker]$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                  NAMES
0995854e2144        wordpress:latest    "/entrypoint.sh apac   About an hour ago   Up About an hour    0.0.0.0:8038->80/tcp   wordpress_1         
99d257ad6e24        mysql:latest        "/entrypoint.sh mysq   About an hour ago   Up About an hour    3306/tcp               mysql_1             
[Trusty@~/code/30days/Docker]$ docker stop 0995854e2144
0995854e2144
[Trusty@~/code/30days/Docker]$ docker stop 99d257ad6e24
99d257ad6e24
[Trusty@~/code/30days/Docker]$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

```

