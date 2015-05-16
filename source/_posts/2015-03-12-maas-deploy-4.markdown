---
layout: post
title: "MAAS Deploy(4)"
date: 2015-03-12 20:52
comments: true
categories: Virtualization
---
From now we will start deploying Juju to our MAAS cluster.    
### Installation of Juju
The installation steps are:    

```
$ sudo add-apt-repository ppa:juju/stable
$ sudo apt-get update
$ sudo apt-get install juju-quickstart juju-core
$ sudo apt-get install juju-local juju

```
### Configuration of Juju
First initialize the configuration:    

```
$ juju init
A boilerplate environment configuration file has been written to /home/Trusty/.juju/environments.yaml.
Edit the file to configure your juju environment and run bootstrap.

```
Now we have to edit the environments.yaml, to manually specify our own configuration.    

```
$ cat /home/Trusty/.juju/environments.yaml
default: maas
environments:
    maas:
        type: maas
        maas-server: 'http://10.17.17.202/MAAS/'
        maas-oauth: 'ntQBr8QTPgeTyfYuMq:HGKFChwM65QXtABNS4:SK7bnuGNDN7fLB9k7HNspYLch4kc6RLs'
        bootstrap-timeout: 1800

```
Run `juju bootstrap` for automatically configure the juju's run environment.   

If you want to know the detailed debug info, simply run `juju bootstrap --show-log` to view the full logs.   
### Deploy Juju Services:    
We want to setup a wordpress APP, so deploy the nodes via following commands:   

```
$ juju deploy wordpress && juju deploy mysql 
Added charm "cs:trusty/wordpress-1" to the environment.
Added charm "cs:trusty/mysql-23" to the environment.

```
Now examine the juju's status via:   

```
$ juju status

```
Then we add the relationship between wordpress and mysql:    

```
$ juju add-relation wordpress mysql

```
Expose wordpress via:     

```
$ juju expose wordpress

```

Upgrade juju version:    

```
$ sudo add-apt-repository ppa:juju/stable
$ sudo vim /etc/apt/sources.list
deb http://ppa.launchpad.net/juju/stable/ubuntu trusty main 
deb-src http://ppa.launchpad.net/juju/stable/ubuntu trusty main 
$ sudo apt-get update && sudo apt-get install juju

```
With the newest juju we could do more safer operation, or some strange things will happen.   


Seems sometimes it's not so stable. Why? Maybe because its configuratiojj

Tried another computer.       
