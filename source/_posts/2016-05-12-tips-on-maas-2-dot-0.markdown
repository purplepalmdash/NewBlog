---
layout: post
title: "Tips On Maas 2.0"
date: 2016-05-12 14:10:48 +0800
comments: true
categories: linux
---
### Installation
Based on Ubuntu16.04, install maas via:    

```
$ sudo apt-get install -y maas
```
After installation, create the default username/password via following command:    

```
$ sudo maas-region createadmin --username=root --email=xxyy@xxyy.com
Password: 
Again: 
```

Now you could login to the `http://YourIP/MAAS` via:    

![/images/2016_05_12_14_25_12_456x494.jpg](/images/2016_05_12_14_25_12_456x494.jpg)    

### Using API to talk
In maas cli, using following steps for generate the API key and use:    

```
# sudo maas-region apikey --username=root
AYnuZY3gWTnpxJb7Kp:AtDG3yUmaDu8tXGzTc:tumR29xsRGL6A7T6M2G7LTETPP5kkDwC
# maas login mymaas http://10.17.17.2/MAAS/api/2.0
AYnuZY3gWTnpxJb7Kp:AtDG3yUmaDu8tXGzTc:tumR29xsRGL6A7T6M2G7LTETPP5kkDwC

You are now logged in to the MAAS server at
http://10.17.17.2/MAAS/api/2.0/ with the profile name 'mymaas'.

For help with the available commands, try:

  maas mymaas --help

```
Later we will use `mymaas` for talk to MAAS Controller.    

### Add Boot Source
Click `Images`, you won't see anything because the images are not downloaded. you could
download it manually via following command:    

```
$ sudo apt-get install simplestreams ubuntu-cloudimage-keyring apache2
$ sudo sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg \
https://images.maas.io/ephemeral-v2/daily/ /var/www/html/maas/images/ephemeral-v2/daily \
'arch=amd64' 'subarch~(generic|hwe-t)' 'release~(trusty|precise|xenial)' --max=1
```
After downloading, the image content will be available under `/var/www/html/`.   

Or, if you downloaded the html files before, do following steps for using your
pre-downloaded packages:     

```
$ tar xJvf html.tar.bz2 -C /var/www/html/
$ sudo maas mymaas boot-sources create url=http://10.17.17.2/mirror/images/ephemeral-v2/releases/ keyring_filename=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg 
``` 
Now there are two boot-sources in maas, delete the default one(Because we are in china,
and its goddamned GFW!)    

```
dash@maascontroller:~$ sudo maas mymaas boot-source delete 1
Success.
Machine-readable output follows:

dash@maascontroller:~$ sudo maas mymaas boot-sources read
Success.
Machine-readable output follows:
[
    {
        "keyring_data": "<memory at 0x7f4e9478b288>",
        "resource_uri": "/MAAS/api/2.0/boot-sources/2/",
        "id": 2,
        "url": "http://10.17.17.2/mirror/images/ephemeral-v2/releases/",
        "keyring_filename": "/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg"
    }
$ 
```
Import boot-sources via:    

```
$ sudo maas mymaas boot-resources import
```

It will takes a little bit time for importing the boot images.   

For adding nodes:   

[https://maas.ubuntu.com/docs2.0/nodes.html](https://maas.ubuntu.com/docs2.0/nodes.html)    
