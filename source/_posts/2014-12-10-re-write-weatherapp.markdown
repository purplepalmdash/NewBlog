---
layout: post
title: "Re-Write WeatherAPP"
date: 2014-12-10 11:17
comments: true
categories: web
---
### Background

### Building the Environment
First clone the Vagrant Repo from:    

```
$ pwd
/media/y/Vagrant/CoreOS
$ git clone https://github.com/coreos/coreos-vagrant.git
$ cd coreos-vagrant
$ cp config.rb.sample config.rb
$ cp user-data.sample user-data

```
#### Cluster Setting
Edit the config.rb, for configurating the instance and the official CoreOS channel:    

```
# Size of the CoreOS cluster created by Vagrant
$num_instances=3
# Official CoreOS channel from which updates should be downloaded
$update_channel='stable'

```
Now start the vagrant and view its status:   

```
$ vagrant up
$ vagrant status
Current machine states:

core-01                   running (virtualbox)
core-02                   running (virtualbox)
core-03                   running (virtualbox)
$ vagrant ssh core-1

```
After you login to the coreOS, you could view the status of this virtual machine. Each of the machine have 1 Core, 1G ram, 20G harddisk.   

### Single Machine
Just comment the following lines of the config.rb:    

```
# $num_instances=3

```
This will bring one instance of vagrant based CoreOS machine.    


### NodeJS
I want to write my APPs using NodeJS, thus I want to setup the NodeJS dev environment on CoreOS based Docker. Following are the steps:    
First configure the proxy of docker:    

```
$ sudo mkdir /etc/systemd/system/docker.service.d
$ sudo vim http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080"
To apply the change, reload the unit and restart docker:
$ systemctl daemon-reload
$ systemctl restart docker

```
Now you could use docker for pulling back some container and run.    

```
$ docker search base
$ docker pull base
$ docker images
$ docker run base /bin/bash -c "ls /"
$ docker run base /bin/bash -c "cat /etc/issue"

``` 
Since the network is not good, I created the droplet on DigitalOcean, and installed CoreOS.  

### Dockerized
[http://blogs.aws.amazon.com/application-management/post/Tx1ZLAHMVBEDCOC/Dockerizing-a-Python-Web-App](http://blogs.aws.amazon.com/application-management/post/Tx1ZLAHMVBEDCOC/Dockerizing-a-Python-Web-App)     
Steps is listed as following:     

```
$ git clone git@github.com:awslabs/eb-py-flask-signup.git
$ cd eb-py-flask-signup
$ git checkout master
$ vim Dockerfile
FROM ubuntu:14.04

# Install Python Setuptools
RUN apt-get install -y python-setuptools

# Install pip
RUN easy_install pip

# Add and install Python modules
ADD requirements.txt /src/requirements.txt
RUN cd /src; pip install -r requirements.txt

# Bundle app source
ADD . /src

# Expose
EXPOSE  5000

# Run
CMD ["python", "/src/application.py"]
$ docker build -t eb-py-sample .
$ docker run -d \
     -e APP_CONFIG=application.config.example \
     -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
     -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
     -p 8080:5000 \
     eb-py-sample

```
Then open http://localhost:8000 to see your own app.   


