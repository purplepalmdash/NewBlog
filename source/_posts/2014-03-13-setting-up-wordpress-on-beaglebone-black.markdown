---
layout: post
title: "Setting Up Wordpress on BeagleBone Black"
date: 2014-03-13 14:50
comments: true
categories: BeagleBone
---
Since BeagleBone Black's hardware configuration is enough for running LAMP, I decide to run wordpress on it. <br />
###Environment
Hardware Configuration:<br />
CPU: Generic AM33XX (Flattened Device Tree)<br />
MEM: MemTotal:         507428 kB<br />
Disk: 1.8'' USB Disk, 30 GB<br />
I also add 512MB swapfile for swapping partition. <br />

Software Configuration:<br />
Kernel: Linux arm 3.8.13-bone30 #1 SMP Mon Nov 18 14:53:22 CST 2013 armv7l GNU/Linux<br />
OS:  Debian GNU/Linux 7 \n \l<br />
###LAMP Configuration
####Install Apache<br />

```
	$ apt-get install apache2

```
After installation, simply open the browser and visit the http://YourIPAddress, if you can find "It works!", then this says the apache server is running now. <br />

####Install MySQL<br />
MySQL is a powerful database management system which is used for organizing and retrieving data.<br />

```
	$ apt-get install mysql-server libapache2-mod-auth-mysql php5-mysql

```
You should be asked to provide the MySQL "root" user password.<br />
Activate MySQL via following command:<br />

```
	$ mysql_install_db
	Change the root password? [Y/n] n 
	Remove anonymous users? [Y/n] Y
	Disallow root login remotely? [Y/n] Y
	Remove test database and access to it? [Y/n] Y
	Reload privilege tables now? [Y/n] Y

```
Now the MySQL is OK, you have to install PHP<br />

####Install PHP<br />
Install following packages:<br />

```
	$ apt-get install php5 libapache2-mod-php5 php5-mcrypt

```
Edit the directory index file:<br />

```
	# cat /etc/apache2/mods-enabled/dir.conf
	<IfModule mod_dir.c>
	          DirectoryIndex index.php index.html index.cgi index.pl index.php index.xhtml index.htm
	</IfModule>
Install modules for using the searched result:<br />
	apt-cache search php5-
Testing PHP on your own apache search:<br />
	root@arm:/home# cat /var/www/info.php
	<?php
	phpinfo();
	?>

```
Restart apache server and view the result:<br />

```
	# /etc/init.d/apache2 restart

```
View the http://YourIpAddress/info.php you can see the php printed out messages. <br />

###Wordpress Setup
Download the latest Wordpress via:<br />

```
	# wget http://wordpress.org/latest.tar.gz

```
Install the ntp server, or you may meet some time and date problem:<br />

```
	# apt-get install ntp

```
Ok, the time is really an issue, gonna be discussed later. <br />
Simply set the time via " date -s "$timestring"" is enough.<br />

Now uncompress the wordpress. <br />

Create the Wordpress Database and User:<br />

```
	# mysql -u root -p
	mysql> CREATE DATABASE wordpress;
	Query OK, 1 row affected (0.01 sec)
	mysql> CREATE USER wordpressuser@localhost;
	Query OK, 0 rows affected (0.00 sec)
	mysql> SET PASSWORD FOR wordpressuser@localhost= PASSWORD("xxxxxxxx");
	Query OK, 0 rows affected (0.00 sec)
	mysql> GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY 'password';
	Query OK, 0 rows affected (0.00 sec)
	mysql> FLUSH PRIVILEGES;
	Query OK, 0 rows affected (0.00 sec)
	mysql> exit
	Bye

```

Setup the WordPress Configuration:<br />

```
	cp ~/wordpress/wp-config-sample.php ~/wordpress/wp-config.php

```
Edit the configuration file:<br />

```
	cat ~/wordpress/wp-config.php
	// ** MySQL settings - You can get this info from your web host ** //
	/** The name of the database for WordPress */
	define('DB_NAME', 'wordpress');
	
	/** MySQL database username */
	define('DB_USER', 'wordpressuser');
	
	/** MySQL database password */
	define('DB_PASSWORD', 'password');

```
Install rsync:<br />

```
	# apt-get install rsync

```
Use rsync for sync to the website's root directory:<br />

```
	# rsync -avP ~/wordpress/ /var/www/

```
Change to the website's root directory and change the ownership to the apache user:<br />

```
	root@arm:/etc# cd /var/www/
	root@arm:/var/www# chown www-data:www-data /var/www -R 
	root@arm:/# chmod g+w /var/www -R 

```
To know the username of apache:

```
	lsof -i 
	Notice the :http part.

```
Install php5-gd , which is the required php module to run wordpress. 

```
	apt-get install php5-gd

```

Now access the page of  /wp-admin/install.php  is OK. or you can access the http://YourIPAddress is ready for install the wordpress on your BeagleBone Black.
