---
layout: post
title: "Use VirtualEnv For Downloading PIP Packages"
date: 2015-06-18 20:56:30 +0800
comments: true
categories: Virtualization
---
In order to use offline installation of pip, I tried following steps for retrieving the packages.    


### Fetch Packages
First install virtualenv packages on CentOS7.    

```
$ sudo yum install -y python-virtualenv
$ virtualenv venv
New python executable in venv/bin/python
Installing Setuptools..............................................................................................................................................................................................................................done.
Installing Pip.....................................................................................................................................................................................................................................................................................................................................done.
$ ls venv
bin  include  lib  lib64
$ source venv/bin/activate
(venv)$      
(venv)$ pip install --download-cache=/home/dash/pipcache cloudmonkey
(venv)$ ls pipcache/
https%3A%2F%2Fpypi.python.org%2Fpackages%2Fsource%2Fa%2Fargcomplete%2Fargcomplete-0.8.9.tar.gz
https%3A%2F%2Fpypi.python.org%2Fpackages%2Fsource%2Fa%2Fargcomplete%2Fargcomplete-0.8.9.tar.gz.content-type
https%3A%2F%2Fpypi.python.org%2Fpackages%2Fsource%2Fc%2Fcloudmonkey%2Fcloudmonkey-5.3.1-0.tar.gz
https%3A%2F%2Fpypi.python.org%2Fpackages%2Fsource%2Fc%2Fcloudmonkey%2Fcloudmonkey-5.3.1-0.tar.gz.content-type
https%3A%2F%2Fpypi.python.org%2Fpackages%2Fsource%2FP%2FPrettyTable%2Fprettytable-0.7.2.tar.bz2
......
(venv)$ mkdir ~/pipcache2
(venv)$ pip install cloudmonkey --download=/home/dash/pipcache2
(venv)$ ls pipcache2
argcomplete-0.8.9.tar.gz    Pygments-2.0.2.tar.gz
cloudmonkey-5.3.1-0.tar.gz  requests-2.7.0.tar.gz
prettytable-0.7.2.tar.bz2
```

### Use Packages
In order to use packages, we did following things.    

```
$ scp xxx@xxx.xxx.xxx.xx:/home/xxx/pipcache2.tar.gz ./
$ tar xzvf pipcache2.tar.gz 
$ pip install --no-index --find-links ~/pipcache2 cloudmonkey
```

Now the package has been installed. enjoy them.    
