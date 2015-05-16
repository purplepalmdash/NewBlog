---
layout: post
title: "Using DO For Building OpenContrail"
date: 2015-01-26 20:32
comments: true
categories: Virtualization
---
Since the network environment is not good(In fact, very bad), because of the GFW, so I have to build the opencontrail packages in digitalOcean. Following is the tips and how-to.    
### Preparation
First we have to get the Latest Ubuntu images, and let it OK for building the OpenContrail:    

```
$ docker search ubuntu
.....
$ docker pull ubuntu
$ docker run -i -t ubuntu /bin/bash
root@4c74f2890dbe:/# apt-get update

```
Now we run into the ubuntu build environment. This is where we want to build the whole opencontrail deb file.    
Install curl and then install repo:    

```
# apt-get install curl
# mkdir -p ~/bin
# curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
# chmod 777 /root/bin/repo
# apt-get install vim
# vim ~/.bashrc
export PATH=/root/bin:$PATH
# source ~/.bashrc
# which repo
/root/bin/repo

```
Now repo became usable in our system.    
Install following packages(So many packages!!!) for preparing the building of the opencontrail:    

```
# apt-get install -y scons git python-lxml wget gcc patch make unzip flex bison g++ libssl-dev autoconf automake libtool pkg-config vim python-dev python-setuptools libprotobuf-dev protobuf-compiler libsnmp-python libboost-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-program-options-dev libboost-python-dev libboost-regex-dev libboost-system-dev libcurl4-openssl-dev google-mock libgoogle-perftools-dev liblog4cplus-dev libtbb-dev libhttp-parser-dev libxml2-dev libicu-dev

```
Use tmux for holding the building context:    

```
# apt-get install tmux
# tmux new -s "BuildContrail"

```
### Clone The Code
Create the directories and then configure the git's username and Email.    

```
# mkdir Code
# cd Code/
#  git config --global user.email kkkttt@gmail.com
# git config --global user.name kkkttt
# ssh-keygen

```
Upload the generate `id_rsa.pub` to the github.com, then let your machine verified by github.    

```
# ssh -T git@github.com
Hi kkkttt! You've successfully authenticated, but GitHub does not provide shell access.

```
Now you could use repo for syncing back the code:    

```
# mkdir -p ~/Code
# cd ~/Code
# repo init -u git@github.com:Juniper/contrail-vnc
# repo sync 

```
### Third-Party
There is little trick in syncing the 3rd party source code back, you have to manually create the folder and let it writable, then modify the source code of the python file:    

```
# mkdir -p /tmp/cache/root/
# chmod -R /tmp/cache/root/
# vim third_party/*.py
_PACKAGE_CACHE='/tmp/cache/' + os.environ['USER'] + '/third_party'
_PACKAGE_CACHE='/tmp/cache/root/' + '/third_party'

```
Now use following command for syncing the 3rd party packages back:    

```
# python third_party/fetch_packages.py

```
### Build
Building is pretty easy, simply type `scons` then everything is automatically on-going.    
Troubles, if you don't specify USER, then the error will be raised, complains the os.environ['USER'] got nothing, then scons will be halt.         
Solution:    

```
# declare -x USER="root"

```
Then the build begin, and it will last for a long time.    
