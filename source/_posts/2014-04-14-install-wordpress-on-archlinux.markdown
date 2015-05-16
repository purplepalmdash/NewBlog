---
layout: post
title: "Install Wordpress on ArchLinux"
date: 2014-04-14 21:53
comments: true
categories: wordpress
---
First install wordpress manually:    

```
	cd /srv/http
	wget https://wordpress.org/latest.tar.gz
	tar xzvf latest.tar.gz
	chown -R http wordpress
	chgrp -R http wordpress

```
Now add a configuration file on wordpress:   

```
	[Trusty@/etc/httpd/conf/extra]$ pwd 
	/etc/httpd/conf/extra
	[Trusty@/etc/httpd/conf/extra]$ cat httpd-wordpress.conf
	Alias / "/srv/http/wordpress/"
	<Directory "/srv/http/wordpress/">
		AllowOverride All
		Options FollowSymlinks
		Order allow,deny
		Allow from all
		php_admin_value open_basedir "/srv/:/tmp/:/srv/http/wordpress/:/usr/share/webapps/:/etc/webapps:$"
	</Directory>

```
In /etc/httpd/conf/httpd.conf file, add:    

```
	# Include wordpress configuration
	Include conf/extra/httpd-wordpress.conf

```
Create the Wordpress Database and User

```
	mysql -u root -p
	CREATE DATABASE wordpress;
	CREATE USER wordpressuser@localhost;
	SET PASSWORD FOR wordpressuser@localhost= PASSWORD("password");
	GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY 'password';
	FLUSH PRIVILEGES;
	exit

```
Configure the configuration file: 

```
	cp ~/wordpress/wp-config-sample.php ~/wordpress/wp-config.php
	sudo nano ~/wordpress/wp-config.php
	// ** MySQL settings - You can get this info from your web host ** //
	/** The name of the database for WordPress */
	define('DB_NAME', 'wordpress');
	
	/** MySQL database username */
	define('DB_USER', 'wordpressuser');
	
	/** MySQL database password */
	define('DB_PASSWORD', 'password');	

```
Configure the php.ini:     

```
	sudo nano /etc/php/php.ini
	extension=mysql.so
	sudo systemctl restart httpd

```
Then visit the url of http://localhost/, install the wordpress and begin to customize. 
