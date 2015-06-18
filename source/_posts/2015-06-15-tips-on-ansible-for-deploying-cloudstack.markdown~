---
layout: post
title: "Tips on Ansible for deploying CloudStack"
date: 2015-06-15 11:38:51 +0800
comments: true
categories: virtualization
---
### Background
Use two nodes, both running CentOS6.6, the Ansible Node have 1-G memory, while the csmanger(CloudStack Manager) Node have 4-G memory.     

Install the epel on Cloudstack manager for installing ansible.    

```
$ wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
$ yum install -y ansible sshpass
```

### Get Nodes
Create the definition of the ansible characters:    

```
[root@CentOS66Base ~]# mkdir -p ~/Code/Ansible
[root@CentOS66Base ~]# cd Code/Ansible/
[root@CentOS66Base Ansible]# vim ansible.cfg
[defaults]
hostfile=/root/Code/Ansible/hosts
[root@CentOS66Base Ansible]# vim hosts
[acs-manager]
10.55.55.72
[root@CentOS66Base Ansible]# cat /etc/hosts
.......
10.55.55.72 acs-manager
[root@CentOS66Base Ansible]# ping acs-manager
PING acs-manager (10.55.55.72) 56(84) bytes of data.
64 bytes from acs-manager (10.55.55.72): icmp_seq=1 ttl=64 time=1.16 ms
```

Add the ssh certification:     

```
[root@CentOS66Base Ansible]# ssh-keyscan acs-manager>>/root/.ssh/known_hosts 
# acs-manager SSH-2.0-OpenSSH_5.3
```

Generate the `id_rsa.pub` locally:     

```
[root@CentOS66Base Ansible]# ssh-keygen -t rsa -b 2048
......
[root@CentOS66Base Ansible]# ls -l -h /root/.ssh/id_rsa.pub 
-rw-r--r--. 1 root root 399 Jun 14 23:59 /root/.ssh/id_rsa.pub
```

Write key installation yml file:    

```
[root@CentOS66Base Ansible]# vim ssh-addkey.yml
---
- hosts: all
  sudo: yes
  gather_facts: no
  remote_user: root

  tasks:

  - name: install ssh key
    authorized_key: user=root
                    key="{{ lookup('file', '/root/.ssh/id_rsa.pub') }}" 
                    state=present
```

!!! Be sure to disable the selinux on the acs-manager machine, then install the sshkey via:     

```
root@CentOS66Base Ansible]# ansible-playbook ssh-addkey.yml --ask-pass
SSH password: 

PLAY [all] ******************************************************************** 

TASK: [install ssh key] ******************************************************* 
changed: [10.55.55.72]

PLAY RECAP ******************************************************************** 
10.55.55.72                : ok=1    changed=1    unreachable=0    failed=0   
```

### Prepare the secondary storage

```
$ sudo apt-get install nfs-kernel-server
$ cd /srv 
$ mkdir nfs4
$ ls
nfs4
$ sudo chown nobody:nogroup /srv/nfs4 
$ sudo vim /etc/exports
# Share access to all networks
/srv/nfs4       *(rw,sync,no_subtree_check)
$ sudo /etc/init.d/nfs-kernel-server start
```

### Start deploying
Deployment sequences:    

```
$ ansible-playbook -i /root/Code/Ansible/hosts  --limit=acs-manager ./cloudstack.yml --tags=base
$ ansible-playbook -i /root/Code/Ansible/hosts  --limit=acs-manager ./cloudstack.yml --tags=mysql
$ ansible-playbook -i /root/Code/Ansible/hosts  --limit=acs-manager ./cloudstack.yml --tags=mysql3306
$ ansible-playbook -i /root/Code/Ansible/hosts  --limit=acs-manager ./cloudstack.yml --tags=csmanagement
```



### Trouble Shooting



Too slow connection:     

```
Use Redsocks. 
By pass 
iptables -t nat -I OUTPUT -d 192.168.0.0/16 -j RETURN
```


CloudMonkey setup:    

```
The host name of this computer does not resolve to an IP address.

[root@acs-manager ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.55.55.72     acs-manager

```

After deployment, visit:    

http://xxx.xx.x.xxx:8080/client
