---
layout: post
title: "Tips On Setup Mesos Cluster"
date: 2016-01-18 10:01:17 +0800
comments: true
categories: Dockerization
---
### Prerequisition
Install on Ubuntu14.04, so first we update to the latest version via:     

```
$ sudo apt-get update && sudo apt-get upgrade -y
```
Prepare the repository of mesos via:    

```
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
# DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
# CODENAME=$(lsb_release -cs)
# echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
```
mesos depends on java8, so we should install java8 on ubuntu machine via following command:    

```
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository ppa:webupd8team/java -y
$ sudo apt-get update
$ sudo apt-get install oracle-java8-installer
```

### Installation

