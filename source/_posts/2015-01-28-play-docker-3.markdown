---
layout: post
title: "Play Docker(3)"
date: 2015-01-28 03:53
comments: true
categories: virtualization
---
### Dockerfile
Dockerfile is like Vagrantfile, for define the configuration of the docker container.    
The steps for creating the Dockerfile is listed as following:    

```
$ mkdir -p ~/Code
$ cd ~/Code && vim Dockerfile 
FROM ubuntu:13.04
MAINTAINER examples@docker.com
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssh-server nginx  supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN echo "daemon off;">>/etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 22 80
CMD ["/usr/bin/supervisord"]
$ vim supervisord.conf 
[supervisord]
nodaemon=true
[program:sshd]
command=/usr/sbin/sshd -D

[program:nginx]
command=/usr/sbin/nginx
user=root
autostart=true

```
Now build the target image with following command:    

```
$ sudo docker build -t test/supervisord .

```
After build, we could use `sudo docker images` for examing the generated images. And use following command for start the sshd and nginx service:    

```
$ sudo docker run -p 2222:22 -p 8080:80 -t -i test/supervisord

```
Now change the root password and you could directly `ssh root@127.0.0.1 -p 2222` or you could directly access [http://1xx.xx.xx.xxx:8080](http://1xx.xx.xx.xxx:8080) for nginx webpages.    

### Fig
Fig is used for swiftly build up a container. You only need to add a fig.yml and specify some simple content, then it could easily assit you building up a container.    
Install fig via following command:    

```
$ wget https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m`
$ sudo mv fig-xxx-xxx /usr/bin/fig
$ sudo chmod 777 /usr/bin/fig

```
Touch the definition files under a specified directory and then use fig for building the whole container:    

```
$ mkdir ~/fig
$ ls
app.py  Dockerfile  fig.yml  requirements.txt
$ cat Dockerfile 
FROM python:2.7
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
$ cat fig.yml 
web:
  build: .
  command: python app.py
  links:
   - db
  ports:
   - "8000:8000"
db:
  image: redis
$ cat requirements.txt 
flask
redis
$ cat app.py 
from flask import Flask
from redis import Redis
import os
app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hello World! I have been seen %s times.' % redis.get('hits')

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)

```
Now use `sudo fig up` then you could let this web service run.    

Met some problems, will be do this at home.   
