---
layout: post
title: "Install And Configure otrs On CentOS"
date: 2014-06-28 19:10
comments: true
categories: otrs
---
### Prerequisite
Install following Packages under CentOS:    

```
$ sudo yum install wget mysql-server mysql php-mysql httpd perl-URI perl-Net-DNS perl-IO-Socket-SSL perl-XML-Parser mod_perl perl-TimeDate perl-Net-DNS procmail perl perl-LDAP perl-Crypt-SSLeay

```
Now configure the mysqld via:    

```
$ sudo chkconfig --levels 235 mysqld on
$ sudo service mysqld start
$ sudo /usr/bin/mysql_secure_installation
$ sudo chkconfig --levels 235 httpd on

```
### Install otrs
Download the otrs from Official website, I downloaed the rpm package for CentOS, then install it via:    

```
sudo rpm -ivh otrs-3.3.8-01.noarch.rpm 

```
As root do following:    

```
# cd /etc/httpd/conf.d/
# cp zzz_otrs.conf otrs.conf
# service httpd start

```
We have to disable SELinux and delete all of the iptables rules:    
Close the SELinux via:    

```
# cat /etc/sysconfig/selinux
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#       enforcing - SELinux security policy is enforced.
#       permissive - SELinux prints warnings instead of enforcing.
#       disabled - SELinux is fully disabled.
# SELINUX=permissive
SELINUX=disabled

```
If you don't disable SELINUX, then you may meet following error message: 

```
消息: Kernel/Config.pm isn't writable!
If you want to use the installer, set the Kernel/Config.pm writable for the webserver user!

```
After disable the SELINUX, Restart the computer.     
Flush all of the pre-defined iptables rules:     

```
# iptables -F
# service iptables save

```

Now open the browser visit: 
[http://Your_Server/ostr/installer.pl](http://Your_Server/ostr/installer.pl)    

When Configurating the database, in the second step, the machine should be selected as `localhost`.       

If you want to delete the otrs database, or if the installation step tells you otrs database exists, you can using following command for drop this database:     

```
[root@CentOS conf.d]# mysqladmin -u root -p  drop otrs
Enter password: 
Dropping the database is potentially a very bad thing to do.
Any data stored in the database will be destroyed.

Do you really want to drop the 'otrs' database [y/N] y
Database "otrs" dropped

```

### Configuration of otrs
The start page at:    
[http://Your_Machine/otrs/index.pl](http://Your_Machine/otrs/index.pl)    

Customer Start page:     
[http://Your_Machine/otrs/customer.pl](http://Your_Machine/otrs/customer.pl)    

Enable the crons tasks(mandantory):    

```
$ su root
# su -m otrs -c 'cd /opt/otrs/bin/ && ./Cron.sh start'
# crontab -l -u otrs

```

Add dynamic field via:    
系统管理->工单设置->动态字段， at the field of "工单", click it and then you can add the customized field.  This will affect customer's submitted ticket forms.    

Change smtp configuration:    
系统管理->系统配置-> 搜索`smtp`, you will meet Core::Sendmail, define the corresponding field and types, then you can use smtp for sending emails.    

### Uninstall otrs
Finally the team didn't use otrs, but its email annoyed me for a long time. Finally I found it's this machine who runs otrs. so I just login to 53, and run:    

```
# rpm -e otrs


```
Also remove the crontab jobs and etc.     

```
# su -m otrs 
bash: /root/.bashrc: Permission denied
bash-4.1$ ./Cron.sh stop
/opt/otrs/bin
Cron.sh - start/stop OTRS cronjobs
Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
done
[root@Linux01 conf.d]# crontab -l -u otrs
no crontab for otrs

```
Also remove the configuration file under /etc/httpd/conf.d/otrs.conf, then restart the httpd server.     
