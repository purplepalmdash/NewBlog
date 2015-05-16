---
layout: post
title: "Setup Wordpress on Ubuntu"
date: 2013-12-23 18:29
comments: true
categories: Linux Web
---
###Material
Just some items on how to setup a wordpress website on Ubuntu12.04 and Ubuntu13.04.     
The tutorial for setting up wordpress on Ubuntu12.04 is located at:    
[https://www.digitalocean.com/community/articles/how-to-install-wordpress-on-ubuntu-12-04](https://www.digitalocean.com/community/articles/how-to-install-wordpress-on-ubuntu-12-04)    

And a tutorial for setting up LAMP server on Ubuntu12.04 is located at:     
[https://www.digitalocean.com/community/articles/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu](https://www.digitalocean.com/community/articles/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu)     

###TroubleShotting
I encountered some problem during setup. Following is the solutions for them.     
####Delete the previous installed wordpress    

```
	# mysqladmin -uXXXX -pXXXXXXXX drop wordpress
	Do you really want to drop the 'wordpress' database [y/N] y

```
Then you can Re-Create the database.    
####Upload file size limitation    
Edit the file limitation via:   

```
	# vim /etc/php5/apache2/php.ini
		post_max_size = 64M
		upload_max_filesize = 64M
	# /etc/init.d/apache2 restart

```
####Reset the default webserver
Change from default nginx to apache2 server: 

```
	$ update-rc.d -f nginx disable 
	$ update-rc.d -f apache2 enable 

```
####Fresh Re-install of apach2
Sometimes you have to re-set the configuration of apache, following steps will let you freshly re-install it. 

```
	$ apt-get remove --purge apache2 apache2-utils php5-cgi php5-fpm libapache2-mod-php5filter libapache2-mod-php5  apache2.2-common
	$ apt-get install  apache2 apache2-utils php5-cgi php5-fpm  apache2.2-common
	$ apt-get install libapache2-mod-php5filter
	$ apt-get install libapache2-mod-php5

```
