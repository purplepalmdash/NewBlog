---
layout: post
title: "Deploy OpenContrail On CentOS With Docker As Hypervisor"
date: 2015-04-07 16:50
comments: true
categories: Virtualization
---
Reference:    
[https://software.intel.com/en-us/blogs/2014/12/28/experimenting-with-openstack-sahara-on-docker-containers](https://software.intel.com/en-us/blogs/2014/12/28/experimenting-with-openstack-sahara-on-docker-containers)    
I wanna enable the docker as hypervisor then it would greatly save the resources, and benefit with docker's rich resources. Following is the steps:    
### Preparation 
First create the image file via:    

```
# qemu-img create -f qcow2 CentOSOpenContrail.qcow2 100G
Formatting 'CentOSOpenContrail.qcow2', fmt=qcow2 size=107374182400 encryption=off cluster_size=65536 
[root:/home/juju/img/CentOSOpenContrail]# pwd
/home/juju/img/CentOSOpenContrail

```
Then create a virtual machine based on KVM, allocate 8G Memory, 4-core, which copies the host CPU configuration.    
### Installation
After installation, update the installed software via:    

```
$ mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup   
$ wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
$ sudo yum makecache
$ sudo yum update -y
$ sudo reboot

```
Install following packages:    

```
# wget https://repos.fedorapeople.org/repos/openstack/openstack-juno/rdo-release-juno-1.noarch.rpm
# rpm -ivh rdo-release-juno-1.noarch.rpm 
# yum install –y https://rdo.fedorapeople.org/rdo-release.rpm
# yum install openstack-packstack

```
Now you could use packstack for installing the packages:    

```
# packstack --gen-answer-file=/root/answer.txt
# packstack --answer-file=/root/answer.txt

```
Install openstack-sahara via following command, the python-tox enable tox for generating the configuration files for sahara:    

```
# yum install openstack-sahara 
# yum install python-tox

```
Create the username and password for sahara to use:    

```
[root@10-17-17-183 etc]# mysql
MariaDB [(none)]> create user 'sahara'@'localhost' identified by 'saharapass';
Query OK, 0 rows affected (0.07 sec)
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| cinder             |
| glance             |
| keystone           |
| mysql              |
| neutron            |
| nova               |
| performance_schema |
| test               |
+--------------------+
9 rows in set (0.00 sec)

MariaDB [(none)]> use mysql
MariaDB [mysql]> show tables;
MariaDB [mysql]> select * from user;
+-----------+----------------+-----------------------------------

```
How to get all of the password configuration information of packstack?   

```
$ cd /etc/
$ grep -i "sql://" ./ -r

```
Create a database named 'saharaDB" and grant it to user sahra:     

```
MariaDB [(none)]> create database saharaDB;
MariaDB [(none)]> grant all on saharaDB.* to 'sahara'@'localhost';
Query OK, 0 rows affected (0.02 sec)

MariaDB [(none)]> quit;
[root@10-17-17-183 etc]# mysql -h 127.0.0.1 -u sahara -p saharaDB
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 1481
Server version: 5.5.40-MariaDB-wsrep MariaDB Server, wsrep_25.11.r4026

Copyright (c) 2000, 2014, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [saharaDB]> 

```
So the syntax for sahara to use is like:    

```
# cat /etc/sahara/sahara.conf
connection = mysql://sahara:saharapass@127.0.0.1/saharaDB
use_neutron=true

# sahara-db-manage --config-file /etc/sahara/sahara.conf upgrade head
INFO  [alembic.migration] Context impl MySQLImpl.
INFO  [alembic.migration] Will assume non-transactional DDL.
INFO  [alembic.migration] Running upgrade None -> 001, Icehouse release
INFO  [alembic.migration] Running upgrade 001 -> 002, placeholder
INFO  [alembic.migration] Running upgrade 002 -> 003, placeholder
INFO  [alembic.migration] Running upgrade 003 -> 004, placeholder
INFO  [alembic.migration] Running upgrade 004 -> 005, placeholder
INFO  [alembic.migration] Running upgrade 005 -> 006, placeholder
INFO  [alembic.migration] Running upgrade 006 -> 007, convert clusters.status_description to LongText
INFO  [alembic.migration] Running upgrade 007 -> 008, add security_groups field to node groups
INFO  [alembic.migration] Running upgrade 008 -> 009, add rollback info to cluster
INFO  [alembic.migration] Running upgrade 009 -> 010, add auto_security_groups flag to node group
INFO  [alembic.migration] Running upgrade 010 -> 011, add Sahara settings info to cluster

```
REgister the service and specify the endpoint:     

```
[root@10-17-17-183 etc]# cat ./nagios/keystonerc_admin                                                                                         
export OS_USERNAME=admin                                                                                                                       
export OS_TENANT_NAME=admin                                                                                                                    
export OS_PASSWORD=5d4e62e79d314477                                                                                                            
export OS_AUTH_URL=http://10.17.17.183:35357/v2.0/ 
[root@10-17-17-183 etc]# pwd                                                                
/etc  
# keystone service-create --name sahara --type data_processing --description "Data processing service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |     Data processing service      |
|   enabled   |               True               |
|      id     | 5f711f0d42754b349931349bd0c325d1 |
|     name    |              sahara              |
|     type    |         data_processing          |
+-------------+----------------------------------+
[root@10-17-17-183 ~]# keystone endpoint-create --service-id $(keystone service-list | awk '/ sahara / {print $2}') --publicurl http://127.0.0.1:8386/v1.1/%\(tenant_id\)s --internalurl http://127.0.0.1:8386/v1.1/%\(tenant_id\)s --adminurl http://127.0.0.1:8386/v1.1/%\(tenant_id\)s --region regionOne
+-------------+------------------------------------------+
|   Property  |                  Value                   |
+-------------+------------------------------------------+
|   adminurl  | http://127.0.0.1:8386/v1.1/%(tenant_id)s |
|      id     |     b2115bab8bd743f589b1ed68eef69b4c     |
| internalurl | http://127.0.0.1:8386/v1.1/%(tenant_id)s |
|  publicurl  | http://127.0.0.1:8386/v1.1/%(tenant_id)s |
|    region   |                regionOne                 |
|  service_id |     5f711f0d42754b349931349bd0c325d1     |
+-------------+------------------------------------------+
[root@10-17-17-183 ~]# systemctl start openstack-sahara-all
[root@10-17-17-183 ~]# systemctl enable openstack-sahara-all
ln -s '/usr/lib/systemd/system/openstack-sahara-all.service' '/etc/systemd/system/multi-user.target.wants/openstack-sahara-all.service'
[root@10-17-17-183 ~]# systemctl status openstack-sahara-all.service

```
More detailed info could be fetched from:     
[http://docs.openstack.org/juno/install-guide/install/apt/content/sahara-install.html](http://docs.openstack.org/juno/install-guide/install/apt/content/sahara-install.html)    
Now login to the [http://10.17.17.183](http://10.17.17.183) then you could visit the Trustyboard. The password is the one we used in the `OS_PASSWORD`.    
Install docker:     

```
$  yum install docker
Or
$  wget https://get.docker.com/builds/Linux/x86_64/docker-latest -O docker
$  docker --version
[root@10-17-17-183 ~]#  usermod -G dockerroot nova
[root@10-17-17-183 ~]# service openstack-nova-compute restart
Redirecting to /bin/systemctl restart  openstack-nova-compute.service
# systemctl restart docker
# systemctl enable docker

```
Install nova-docker support:     

```
$  yum install python-pip
$  pip install -e git+https://github.com/stackforge/nova-docker#egg=novadocker
$  cd src/novadocker/
$  python setup.py install
$ vim /etc/nova/nova.conf
[DEFAULT]
compute_driver = novadocker.virt.docker.DockerDriver

```
Edit the nova's rootwrap like following:     

```
[root@10-17-17-183 nova]# mkdir rootwrap.d
[root@10-17-17-183 nova]# cd rootwrap.d/
[root@10-17-17-183 rootwrap.d]# touch docker.filters
[root@10-17-17-183 rootwrap.d]# vim docker.filters 
[Filters]
# nova/virt/docker/driver.py:'ln', '-sf', '/var/run/netns/.*'
ln: CommandFilter, /bin/ln, root
[root@10-17-17-183 rootwrap.d]# vim /etc/nova/rootwrap.conf 
[root@10-17-17-183 rootwrap.d]# pwd
/etc/nova/rootwrap.d

```
Edit the glance-api.conf

```
[root@10-17-17-183 glance]# vim ./glance-api.conf 
[DEFAULT]
container_formats = ami,ari,aki,bare,ovf,docker
[root@10-17-17-183 glance]# pwd
/etc/glance

```
Create the ubuntu Container images via following commands:    

```
$ docker pull ubuntu
$ docker save ubuntu | glance image-create --is-public=True --container-format=docker --disk-format=raw --name ubuntu_container

```



 
