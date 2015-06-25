---
layout: post
title: "For deploying 148 Tips"
date: 2015-06-25 11:56:41 +0800
comments: true
categories: WH
---
The whole deployment procedure is listed as following:    

```
# cobbler system add --name=node148 --profile=CentOS-6.5-x86_64 --mac=52:54:00:9e:ea:58 --interface=eth0 --ip-address=10.47.58.148 --hostname=node148 --gateway=10.47.58.1 --dns-name=node148
# vim /root/Code/Ansible/hosts
[node148]
10.47.58.148
# ssh-keyscan 10.47.58.148>>/root/.ssh/known_hosts 
# ansible-playbook /root/Code/Ansible/ssh-addkey.yml --ask-pass
# vim /root/Code/Ansible/CloudStack-Ansible-Playbook/cloudstack.yml
      ManagementIP: 10.47.58.148
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node148 /root/Code/Ansible/CloudStack-Ansible-Playbook/cloudstack.yml --tags=pip
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node148 /root/Code/Ansible/CloudStack-Ansible-Playbook/cloudstack.yml --tags=base
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node148 /root/Code/Ansible/CloudStack-Ansible-Playbook/cloudstack.yml --tags=mysql
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node148 /root/Code/Ansible/CloudStack-Ansible-Playbook/cloudstack.yml --tags=mysql3306
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node148 /root/Code/Ansible/CloudStack-Ansible-Playbook/cloudstack.yml --tags=csmanagement
```

Or, all-in-one for tags:     

```
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node149 /root/Code/Ansible/CloudStack-Ansible-Playbook/cloudstack.yml --tags=pip,base,mysql,mysql3306,csmanagement 
```
