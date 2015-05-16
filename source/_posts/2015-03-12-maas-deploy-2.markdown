---
layout: post
title: "MAAS Deploy(2)"
date: 2015-03-12 18:43
comments: true
categories: Virtualization
---
We just continue to use MAAS for deploying cluster.      
### Images
Install following packages for enable local installation repository:     

```
$ sudo apt-get install simplestreams ubuntu-cloudimage-keyring apache2
$ sudo apt-get install iptraf nethogs

```
Run following commands for importing the images of mass from official repository to local webserver.     

```
root@MassTestOnUbuntu1404:~# sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg http://maas.ubuntu.com/images/ephemeral-v2/daily/ /var/www/html/maas/images/ephemeral-v2/daily 'arch=amd64' 'subarch~(generic|hwe-t)' 'release~(trusty|precise)' --max=1

```
If you have the pre-downloaded packages, simply de-compress it to the corresponding directory.     

```
root@MassTestOnUbuntu1404:/var/www/html/maas/images# mv ephemeral-v2/ ephemeral-v2.back
root@MassTestOnUbuntu1404:/var/www/html/maas/images# tar xjvf /home/Trusty/ephemeral-v2.tar.bz2  -C ./

```
After de-compression, your local image service could be detected via visit following webpage:    
[http://10.17.17.202/maas/images/ephemeral-v2/daily/streams/v1/index.sjson](http://10.17.17.202/maas/images/ephemeral-v2/daily/streams/v1/index.sjson)    

Visit following webpage, then edit the default gateway and the DNS server:    
[http://10.17.17.202/MAAS/networks/maas-eth0/edit/](http://10.17.17.202/MAAS/networks/maas-eth0/edit/)    
Default GateWay:   10.17.17.1    
DNS Servers: 114.114.114.114     
Then `Save Network` can let you save your network configuration.    

Click Configuration Button, and update the `Ubuntu -> Main archive (required)` from:    
http://archive.ubuntu.com/ubuntu     
to:    
http://mirrors.aliyun.com/ubuntu/    
This repository enable the installed system for retrieving the install packages, use aliyun we could get much more faster speed.    

Change the `Boot Images -> Sync URL (required)` from:    
http://maas.ubuntu.com/images/ephemeral-v2/releases/    
to     
http://10.17.17.202/maas/images/ephemeral-v2/daily/   
This will enable the Boot Images Sync URLs, use local repository will greatly improve the bootup speed.  

Now build the Images like following images:    
![/images/2015_03_12_19_23_06_942x396.jpg](/images/2015_03_12_19_23_06_942x396.jpg)    

After a while, your Boot Image will be ready.    

### Add Maas Ssh Key
Do following steps for generate the ssh key pairs for user maas:    

```
$ sudo mkdir /home/maas
$ sudo chown maas:maas /home/maas/
$ sudo chsh maas
Changing the login shell for maas
Enter the new value, or press ENTER for the default
        Login Shell [/bin/false]: /bin/bash
Trusty@MassTestOnUbuntu1404:~$ sudo su - maas
maas@MassTestOnUbuntu1404:~$ ssh-keygen 
Generating public/private rsa key pair.

```
After these steps, copy the /home/maas/.ssh/id_rsa.pub to your clipboard, then copy it under:    
[http://10.17.17.202/MAAS/account/prefs/sshkey/add/](http://10.17.17.202/MAAS/account/prefs/sshkey/add/)   
Now the ssh-key has been added into your MAAS system.   

You could also copy the api key of your maas, later we will use it.    
Mine is:   `ntQBr8QTPgeTyfYuMq:HGKFChwM65QXtABNS4:SK7bnuGNDN7fLB9k7HNspYLch4kc6RLs`    

Now the maas controller is ready, next step is create the virtual machine and let it be managed by controller.    
