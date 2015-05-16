---
layout: post
title: "Run BBB building in server"
date: 2014-10-14 10:43
comments: true
categories: embedded
---
### Background
Since building is heavy task to CPU, I decide to use the server in lab for building

### Packages
We need to install following packages for setting up the building environment:     

```
zypper in git patch u-boot-tools git ncurses-devel dpkg dpkg-devel dpkg-lang

```
Use git for acrossing the firewall of company:    

```
> git config --global user.email xxxx@gmail.com
> git config --global user.name xxxx
> cat ~/.gitconfig
[user]
	email = xxxx@gmail.com
	name = xxx 

```
Then we compile a cross Firewall tool and tell git for using it.    

```
$ gcc -o connect connect.c
$ sudo cp connect /usr/bin
$ sudo chmod 777 /usr/bin/connect
$ sudo chmod 777 /usr/bin/myproxy
$ cat /usr/bin/myproxy
/usr/bin/connect -H 127.0.0.1:9001 $@

```
Now add the following lines in ~/.gitconfig:    

```
[core]
	gitproxy = /usr/bin/myproxy


```
Testing the git via:    

```
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/stable-queue.git

```
### Building
Be sure the directory had the same as in laptop.   that is:     

```
> pwd
/media/y/embedded/BBB/Kernel/bb-kernel

```
For long-time building, I install tmux for handling the process:    

```
zypper in tmux

```
Under the folder, run `build_kernel.sh` then you could get the Linux Kernel.    
fakeroot should be installed in openSUSE:    

```
http://software.opensuse.org/package/fakeroot?search_term=fakeroot
rpm -ivh fakeroot-1.20-1.18.x86_64.rpm

```
You should change the following files to enable the hostname:    

```
Linux59:~ # cat /etc/hostname
Linux59
Linux59:~ # cat /etc/hosts
127.0.0.1	localhost.localdomain	localhost
127.0.0.1	Linux59.localdomain	Linux59

```
Now run hostname via:    

```
Linux59:~ # hostname --fqdn
Linux59.localdomain

```
Now run `./build_deb.sh` you could get the deb file.    


### Building Angstrom
First you should check out the git source from github:    

```
git clone git://github.com/Angstrom-distribution/setup-scripts.git

```
Then run:    

```
$ MACHINE=beagleboard ./oebb.sh config beagleboard


```

### Trouble-Shooting
First I met tmux issue. so I installed the tmux in router(OpenWRT):    

```
opkg update
opkg install tmux

```
Then I use tmux in router,create the new session which holds the  ssh connection to the Server.     



Then in family computer, the git proxy configuraiton won't reset even if I update the ~/.gitconfig. This problem didn't solved.  I don't know why. 
