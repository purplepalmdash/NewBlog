---
layout: post
title: "Dockerize Wordpress On DigitalOcean's CoreOS"
date: 2014-12-13 14:28
comments: true
categories: web
---
### Wordpress
Install it via:    

```
$ docker pull tutum/wordpress

```
Run it via:    

```
$ docker run -p 80:80 tutum/wordpress &

```
Now configure the backend, and you could directly access `http://Your_IP_Address` for this wordpress website.    
### Import Database And Static Files
Since I have an old website, I want to import it in this container, following is the steps of how-to.    
The exising database runs on Debian 7, and its platform is arm-based, see if we could directly retrieve the wordpress and extract them into it.  
#### Extract the MYSQL Datafile
Use mysqldump for extracting the existing wordpress file    

```
$ mysqldump -u root -p[root-password] wordpress>~/wordpress.mysql

```
Then copy the `wordpress.mysql` to the remote server.    

#### Replacement
Be sure to use gedit for replacing the old `fxx***.iiiouge.biz:7777` to `1xx.xxx.xxx.xxx` then all of your links will be acts well.   
Then upload the /var/www/ directory to your server's corresponding directory, here ours is `/var/www/html`, eg. `/app`    

#### Import the MYSQL Datafile
Attached to running wordpress in DO via:    

```
$ docker ps
CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS              PORTS                          NAMES
cfddafcc96f5        tutum/wordpress:latest   "/run.sh"              25 hours ago        Up 25 hours         3306/tcp, 0.0.0.0:80->80/tcp   drunk_brown         
$ docker exec -it cfddafcc96f5 bash

```
This will give you a terminal for accessing the running container. Examine the wordpress running environments:     
The WP files are located at `/var/www/html`, the mysql file locates at `/var/lib/mysql/wordpress`, then how to import the old wordpress website is the things we want to solve.      
Install phpMyAdmin for importing the database:    

```
$ sudo apt-get install phpmyadmin apache-utils
$ sudo vim /etc/apache2/apache2.conf
Include /etc/phpmyadmin/apache.conf
$ sudo service apache2 restart
Include /etc/phpmyadmin/apache.conf
$ sudo service apache2 restart

```
Now you could directly access the phpMyAdmin page with username root and empty password, this is dangerous, but we just for demononstration, needn't care it.   
Use phpMyAdmin for importing the sql file which we extracted from the old wordpress.    
#### Trouble shooting
When uploading the www file and replaced, the connection shows:     

```
数据库连接错误
您在wp-config.php文件中提供的数据库用户名和密码可能不正确，或者无法连接到localhost上的数据库服务器，这意味着您的主机数据库服务器已停止工作。

您确认您提供的用户名和密码正确么？
您确认您提供的主机名正确么？
您确认数据库服务器运行正常么？

```
This is because we provided the wrong password for the mysql, change it to the username `root` and nopassword.     

Restart the apache2 server now your website acts good.    

#### Hide phpMyAdmin Page the username `root` and nopassword.     


```
$ sudo nano /etc/phpmyadmin/apache.conf 
<Directory /usr/share/phpmyadmin>
        Options FollowSymLinks
        DirectoryIndex index.php
        AllowOverride All
        [...]

```
Add the htaccess method via:     

```
$ sudo nano /usr/share/phpmyadmin/.htaccess
AuthType Basic
AuthName "Restricted Files"
AuthUserFile /etc/apache2/.phpmyadmin.htpasswd
Require valid-user

```
Then set the password for root via:    

```
$ sudo htpasswd -c /etc/apache2/.phpmyadmin.htpasswd root

```
After doing this, restart the apache2 service, now your phpMyAdmin page is under the protection of the username and the password.    

