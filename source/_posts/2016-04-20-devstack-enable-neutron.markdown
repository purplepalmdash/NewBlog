---
layout: post
title: "DevStack Enable Neutron"
date: 2016-04-20 11:11:54 +0800
comments: true
categories: virtualization
---
### Steps
Install steps are listed as following:    

First as root user, create the initial stack user via:   

```
# git clone https://git.openstack.org/openstack-dev/devstack
# tools/create-stack-user.sh 
# passwd stack
```
Now login with user `stack`, clone the repository and begin devstack installation:    

```
$ git clone https://git.openstack.org/openstack-dev/devstack
$ cd devstack
$ git checkout stable/liberty
$ cp samples/local.conf ./
$ vim local.conf
```

The `local.conf` file should added following items:    

```


# use TryStack git mirror
GIT_BASE=http://git.trystack.cn
NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
```
Add following configurations:    

![/images/2016_04_21_10_46_16_505x495.jpg](/images/2016_04_21_10_46_16_505x495.jpg)    

Now stacking the devstack:   

```
$ ./stack.sh
```
