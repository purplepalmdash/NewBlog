---
layout: post
title: "Change IP In DevStack"
date: 2016-04-18 12:15:35 +0800
comments: true
categories: Virtualization
---
### Tips
After changing the IP Address of the DevStack machine, do following for re-installing
the envs:    

```
$ ssh stack@Your_IP
stack@packer-PerforceTest:~$ pwd
/opt/stack
stack@packer-PerforceTest:~$ cd devstack/
stack@packer-PerforceTest:~/devstack$ ./unstack.sh && ./stack.sh 
```

Now visiting your `http://Your_New_IP/dashboard` you will got the openstack dashborad.   
