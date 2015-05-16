---
layout: post
title: "Download Android Source Code on RaspberryPI"
date: 2014-05-04 09:49
comments: true
categories: raspberryPI
---
Just a try. I don't think I will use raspberryPI for developing, but using it for downloading code is a good idea.    
###Go Back Home
My raspberryPI is behind the router, so I have to use a ssh tunnel to reach raspberryPI.    
Setting up tunnel:         

```
$ ssh -L 2230:10.0.0.230:22 Tomcat.xxx.xx.xxx -l root

```
Login on local port:    

```
$ ssh root@localhost -p 2230

```
Now we have a terminal which could reach raspberry PI.    
###Package Preparation
Since the OS on my raspberryPI is ArchLinux, I have to install following packages:     

```
$ pacman -S w3m tmux lynx

```

###Account Setting
Use w3m for accessing https://android.googlesource.com/new-password

But, remember, I have a BBB which also runs at home, so I can also use it. 

```
$ apt-get install elinks

```
Use elinks for making connection to https://android.googlesource.com/new-password, remember the username, and the machine and login name, just copy them into your ~/.netrc, and make sure you have the right priviledge for the file ~/.netrc.    
###Repo sync
This will take for a long~long time, depending on your bandwidth:  

```
repo init -u https://android.googlesource.com/a/platform/manifest -b master

```
then we use the following file for sync the repo:    

```sh autodown.sh
#!/bin/bash

while [ 1 ]
do
    repo sync -j8
    if [ "$?" = "0" ] ; then
        echo "rsync completed normally"
        exit
    else
        echo "Rsync failure. Backing off and retrying..."
        sleep 1
    fi
done

```
Now call tmux for holding the sync procedure:   

```
$ tmux new -s Android
$ /bin/bash ./autodown.sh 2>&1 | tee autodown.log
$ ctrl+b d

```
The sync process now is held in tmux session. Let it go, next time when you want to see the procedure, just ssh to the board use:   

```
tmux a -t Android

```

