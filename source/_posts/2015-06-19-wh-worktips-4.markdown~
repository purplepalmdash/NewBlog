---
layout: post
title: "WH Worktips(4)"
date: 2015-06-19 11:32:04 +0800
comments: true
categories: Virtualization
---
### A Whole Deployment

```
$ pwd
/home/juju/img/WolfHunter/WH
$ qemu-img create -f qcow2 z_Node113.qcow2 100G
$ 
```

Create Virtual Machine:    

![/images/2015_06_19_11_39_45_474x366.jpg](/images/2015_06_19_11_39_45_474x366.jpg)    

Memory:    

![/images/2015_06_19_11_40_51_477x363.jpg](/images/2015_06_19_11_40_51_477x363.jpg)    


![/images/2015_06_19_11_41_58_482x369.jpg](/images/2015_06_19_11_41_58_482x369.jpg)    

Click `Customize configuration before install`:     

VirtIO Disk 1:   

![/images/2015_06_19_11_43_22_478x309.jpg](/images/2015_06_19_11_43_22_478x309.jpg)    

Virtual Network Interface:    

![/images/2015_06_19_11_44_12_553x205.jpg](/images/2015_06_19_11_44_12_553x205.jpg)    

Notice the mac address is `52:54:00:9a:73:1a`.     

### Cobbler Customization
Define the node:    

```
[root@z_WHServer ~]#  cobbler system add --name=node113 --profile=CentOS-6.5-x86_64 --mac=52:54:00:9a:73:1a --interface=eth0 --ip-address=10.47.58.113 --hostname=node113 --gateway=10.47.58.1 --dns-name=node113
```

### Begin Installation

![/images/2015_06_19_11_49_09_685x401.jpg](/images/2015_06_19_11_49_09_685x401.jpg)    


### Configure

Notice the ssh failed to 112 because we poweroff this node.   

```
ssh-keyscan 10.47.58.113>>/root/.ssh/known_hosts 
# 10.47.58.113 SSH-2.0-OpenSSH_5.3

# cd /root/Code/Ansible
# ansible-playbook ssh-addkey.yml --ask-pass
SSH password: 

PLAY [all] ******************************************************************** 

TASK: [install ssh key] ******************************************************* 
changed: [10.47.58.113]
fatal: [10.47.58.112] => SSH Error: ssh: connect to host 10.47.58.112 port 22: Connection timed out
    while connecting to 10.47.58.112:22
It is sometimes useful to re-run the command using -vvvv, which prints SSH debug output to help diagnose the issue.

PLAY RECAP ******************************************************************** 
           to retry, use: --limit @/root/ssh-addkey.retry

10.47.58.112               : ok=0    changed=0    unreachable=1    failed=0   
10.47.58.113               : ok=1    changed=1    unreachable=0    failed=0  
```

Check:    

```
# ansible all -m shell -a "uptime"
10.47.58.113 | success | rc=0 >>
 04:32:21 up 32 min,  3 users,  load average: 0.00, 0.00, 0.00

10.47.58.112 | FAILED => SSH Error: ssh: connect to host 10.47.58.112 port 22: No route to host
    while connecting to 10.47.58.112:22
It is sometimes useful to re-run the command using -vvvv, which prints SSH debug output to help diagnose the issue.
```
Deployed via:    

```
# cd /root/Code/Ansible/CloudStack-Ansible-Playbook
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=base
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=mysql
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=mysql3306
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=csmanagement -vvvv
```

Now you could enjoy a new node's ansible deployment.    
