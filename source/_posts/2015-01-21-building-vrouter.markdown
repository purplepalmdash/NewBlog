---
layout: post
title: "Building vrouter"
date: 2015-01-21 23:12
comments: true
categories: SDN
---
### Preparation
First we should get repo, while this little kit has been banned via GFW, thus we should use DO machine for getting it down and ssh to local machine.     

```
$ mkdir ~/bin
$ PATH=~/bin:$PATH
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
$ tail ~/.zshrc
# Add our own bin/ folder for using different tools:    
export PATH="$PATH:$HOME/bin"

```
Now we could use repo.    
### Oops, git is old!
The default version of git is too old in CentOS, thus we have to upgrade it. , repo needs git version newer than 1.7.2, or you won't get any results from github.    

```
~% git --version
git version 1.7.1

```
Install necessary packages:    

```
$ sudo yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker

```
Now build and install git via:    

```
$ sudo mkdir -p /usr/local/git
$ wget https://www.kernel.org/pub/software/scm/git/git-1.9.4.tar.gz
$ tar xzvf git-1.9.4.tar.gz
$ cd git-1.9.4
$ make prefix=/usr/local/git all
$ sudo make prefix=/usr/local/git install
$ echo "export PATH=/usr/local/git/bin:$PATH">>~/.zshrc
$ source ~/.zshrc
$ git --version
git version 1.9.4

```
Now the git is already the newer version, we could use it together with repo.       
### Sync Repository
Unfortunately we have been blocked by GFW, so we have to enable little tool proxychains:    

```
$ git clone https://github.com/rofl0r/proxychains-ng.git 
$ cd proxychains-ng
$ ./configure --prefix=/usr
$ make
$ sudo make install
$ sudo make install-config
$ sudo vim /etc/proxychains.conf
# defaults set to "tor"
#socks4 	127.0.0.1 9050
socks5 	127.0.0.1 1395

```
Now we could use proxychains for syncing the repositories, simply init the repo via:    

```
$ cd /home/xxx.xxxxx/Code/Vrouter_repo
$ proxychains4 repo init -u git@github.com:Juniper/contrail-vnc -m vrouter-manifest.xml

```
Now sync the repository via:    

```
$ proxychains4 repo sync

```
### Build
After syncing the code, we could finally build this repository, build it via;    

```
$ scons vrouter

```
Seems boost is pretty old on CentOS 6.6, thus we have to manually compile boost on our system.    
Since some packages are pretty old on CentOS, I switched to the ubuntu for developing.    
