---
layout: post
title: "Build CentOS Image For MAAS"
date: 2015-04-29 17:31
comments: true
categories: Virtualization
---
MAAS could only deploy Ubuntu in its official support, this artcle will introduce how to Build CentOS based images.      
### Preparation
First you need a Ubuntu14.04 machine with kvm enabled.      

```
$ sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
$ sudo apt-get install build-essential

```
### Get Build Scripts
Get the source code from the launchpad, and run following command for preparing the building environment.   

```
$  bzr branch lp:maas-image-builder
$ cd maas-images-builder
$ make install-dependencies

```
For speed-up building, I use china mainland's repository,    
Replace the `http://mirror.centos.org/centos/6/os/x86_64` like following:    

```
$ vim ./src/mib/builders/centos.py
      #"http://mirror.centos.org/centos/6/os/i386")
      "http://mirrors.aliyun.com/centos/6/os/i386")
      #"http://mirror.centos.org/centos/6/os/x86_64")
      "http://mirrors.aliyun.com/centos/6/os/x86_64")
  #"http://mirror.centos.org/centos/7/os/x86_64")
  "http://mirrors.aliyun.com/centos/7/os/x86_64/")

$ vim ./contrib/centos/centos6/centos6-amd64.ks
repo --name="repo0" --baseurl=http://mirrors.aliyun.com/centos/6/os/x86_64/
repo --name="repo1" --baseurl=http://mirrors.aliyun.com/centos/6/updates/x86_64/
repo --name="repo2" --baseurl=http://mirrors.aliyun.com/epel/6/x86_64/

```
### Build Images
Install python-dev and begin to make:   

```
# apt-get install python-dev
# make

```
Now begin to generate the image:    

```
#./bin/maas-image-builder -o centos6-amd64-root-tgz centos --edition 6

```
On-Building:     
![/images/2015_04_29_18_00_43_674x328.jpg](/images/2015_04_29_18_00_43_674x328.jpg)    

After building the image is listed as:    

```
# ls -l centos6-amd64-root-tgz 
-rw-r--r-- 1 root root 353086181 Apr 29 13:16 centos6-amd64-root-tgz

```

### Import Images
First login into your own profile with following command:    

```
$ maas login my-maas http://10.17.17.202/MAAS/api/1.0 ntQBr8QTPgeTyfYuMq:xxxxxxxxxxxxxxxxxxxxxxxxx7HNspYLch4kc6RLs
$ maas my-maas boot-sources read

```
Above command will readout the boot-sources, now we need to import our newly-built images, import it via:    

```
$ maas my-maas boot-resources create name=centos/centos6 architecture=amd64/generic content@=/home/Trusty/centos6-amd64-root-tgz

```

### Login    
Use following commands:    

```
maas@MassTestOnUbuntu1404:~$ ssh cloud-user@10.17.17.172
The authenticity of host '10.17.17.172 (10.17.17.172)' can't be established.
ECDSA key fingerprint is a5:57:5b:d1:ac:c0:8f:67:32:43:d8:6f:17:67:65:cb.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.17.17.172' (ECDSA) to the list of known hosts.
[cloud-user@CentOS ~]$ ls
[cloud-user@CentOS ~]$ cat /etc/issue
\S
Kernel \r on an \m

[cloud-user@CentOS ~]$ uname -a
Linux CentOS 3.10.0-229.1.2.el7.x86_64 #1 SMP Fri Mar 27 03:04:26 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux

```


From Now on,you could use CentOS 6 for deploying!!!!!!!!!!!!!!1                     

ENJOY IT!!!!!!!

### Trouble Shooting
The version could not be speicified via --edition, everytime we got CentOS 7 based image , so we need to manually change the file:     

```
 root@BuildMaasImage:~/Code/once# vim src/mib/builders/centos.py
    def populate_parser(self, parser):
        """Add parser options."""
        parser.add_argument(
            #'--edition', default='7',
            #help="CentOS edition to generate. (Default: 7)")
            '--edition', default='6',
            help="CentOS edition to generate. (Default: 6)")



```
Now re-generate the image again, we got CentOS 6.5 based images.   
To-Be-Done:    
How to generate the CentOS 6.5/6.4/6.3 version? we always get the newest CentOS 6 images.    
