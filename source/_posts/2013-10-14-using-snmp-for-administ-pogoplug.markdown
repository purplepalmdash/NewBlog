---
layout: post
title: "Using SNMP for administ PogoPlug"
date: 2013-10-14 07:49
comments: true
categories: Linux
---
###Preparation
For using SNMP for administrating PogoPlug, we have to install following packages first:  

```
	# apt-get install snmpd smartmontools super
```

snmpd is the daemon process for snmp, smartmontools is the monitor tools for harddisk, super let you run daemon process in super priviledge.   
###Configuration
Configure snmp firstly.  

###Client Configuration
Install the webserver using the following command:  

```
	$ pacman -S apache php php-apache mariadb
```

After install the packages, if you want to change the configuration file, directly edit the /etc/httpd/conf/httpd.conf or extra/httpd-default.conf, then using systemd to restart the httpd daemon.  
Change priviledge of the public_html directory:

```
	$ chmod o+x ~
	$ chmod o_x ~/public_html
	# A more safe way for controlling the safety
	# usermod -aG groupname http
```

###SSL Configuration
Generate a new self-signed certificate(key size and the number of days of validity will be customized):

```
	# openssl genrsa -out server.key 2048
	Generating RSA private key, 2048 bit long modulus
	..........................+++
	...........................................................................................................................................................+++
	e is 65537 (0x10001)
	[root@XXXyyy conf]# ls
	extra  httpd.conf  magic  mime.types  server.key
	[root@XXXyyy conf]# chmod 600 server.key
	[root@XXXyyy conf]# openssl req -new -key server.key -out server.csr
	You are about to be asked to enter information that will be incorporated
	into your certificate request.
	What you are about to enter is what is called a Distinguished Name or a DN.
	There are quite a few fields but you can leave some blank
	For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	Country Name (2 letter code) [AU]:
	State or Province Name (full name) [Some-State]:
	Locality Name (eg, city) []:
	Organization Name (eg, company) [Internet Widgits Pty Ltd]:
	Organizational Unit Name (eg, section) []:
	Common Name (e.g. server FQDN or YOUR name) []:
	Email Address []:
	
	Please enter the following 'extra' attributes
	to be sent with your certificate request
	A challenge password []:
	An optional company name []:
	[root@XXXyyy conf]# openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
	Signature ok
	subject=/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd
	Getting Private key
	[root@XXXyyy conf]# ls
	extra  httpd.conf  magic  mime.types  server.crt  server.csr  server.key
```

Then, uncomment the line containing following lines in /etc/httpd/conf/httpd.conf:

```
	Include conf/extra/httpd-ssl.conf
	Restart httpd to see the result. 
```

###Enable php
Place Following line after LoadModule dir_module modules/mod_dir.so in /etc/httpd/conf/httpd.conf:

```
	LoadModule php5_module modules/libphp5.so
Place following line at the end of the Include list:
	Include conf/extra/php5_module.conf
Make sure you uncommented following line:
	TypesConfig conf/mime.types
	# Optional uncomment:
	MIMEMagicFile conf/magic
Add this line in /etc/httpd/conf/mime.types:
	application/x-httpd-php       php    php5
Make sure libphp5.so is under /etc/httpd/modules, if not, you may forgot to install php-apache.  
Test the php via following line under test.php:
	<?php phpinfo(); ?>
```

###Configure MariaDB
Uncomment at least one line under /etc/php/php.ini:

```
	extension=pdo_mysql.so
	extension=mysqli.so
	extension=mysql.so
```

###Mysql Configuration

```
	[root@XXXyyy http]# mysqld_safe --skip-grant-tables &
	[1] 26315
	[root@XXXyyy http]# 131014 16:55:07 mysqld_safe Logging to '/var/lib/mysql/XXXyyy.err'.
	131014 16:55:07 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql
	
	[root@XXXyyy http]# mysql -u root mysql
	Welcome to the MariaDB monitor.  Commands end with ; or \g.
	Your MariaDB connection id is 6
	Server version: 5.5.33a-MariaDB-log Source distribution
	
	Copyright (c) 2000, 2013, Oracle, Monty Program Ab and others.
	
	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
	
	MariaDB [mysql]> UPDATE mysql.user SET Password=PASSWORD('******') WHERE User='root';
	Query OK, 4 rows affected (0.00 sec)
	Rows matched: 4  Changed: 4  Warnings: 0
	
	MariaDB [mysql]> FLUSH PRIVILEGES;
	Query OK, 0 rows affected (0.00 sec)
	
	MariaDB [mysql]> exit
	Bye
	[root@XXXyyy http]# systemctl start mysqld
```


###CACTI configuration
Install cacti via:

```
	$ pacman -S cacti
	$ pacman -S php-snmp
```

uncomment the following lines in /ec/php/php.ini:

```
	;extension=mysql.so
	;extension=sockets.so
	;extension=snmp.so
	open_basedir=...
	;date.timezone =
```

Start mysqld:

```
	$ systemctl enable mysqld.service
	$ systemctl start mysqld.service
```
Start snmpd:

```
	$ systemctl enable snmpd
	$ systemctl start snmpd
```

Change the configuration file /etc/httpd/conf/httpd.conf, inside <Directory "/srv/http"> block, ensure you have:

```
	AllowOverride All
```

Create the mysql based db:

```
	$ mysqladmin -u root -p create cacti
	Enter password: 
```

Generate the sql table using existing template:

```
	[root@XXXyyy http]# mysql -u root -p cacti < /usr/share/webapps/cacti/cacti.sql
	Enter password: 
```

Update the configuration of the database, you can replace the password from "some_password" to your own password.

```
	[root@XXXyyy http]# mysql -u root -p
	Enter password: 
	Welcome to the MariaDB monitor.  Commands end with ; or \g.
	Your MariaDB connection id is 10
	Server version: 5.5.33a-MariaDB-log Source distribution
	
	Copyright (c) 2000, 2013, Oracle, Monty Program Ab and others.
	
	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
	
	MariaDB [(none)]> GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'some_password';
	Query OK, 0 rows affected (0.00 sec)
	
	MariaDB [(none)]> FLUSH PRIVILEGES;
	Query OK, 0 rows affected (0.00 sec)
	
	MariaDB [(none)]> exit
	Bye
```

Change the username and password of the config.php of cacti:

```
	$ vim  /usr/share/webapps/cacti/include/config.php
	$ database_username = "cacti";
	$ database_password = "some_password";
```

Clean up the cacti directory:

```
	chown -R http:http /usr/share/webapps/cacti/{rra,log}
	rm /usr/share/webapps/cacti/.htaccess
	chmod +x /usr/share/webapps/cacti/{cmd,poller}.php /usr/share/webapps/cacti/lib/ping.php
```

Install caccti-spine, a fast poller for cacti, from AUR. Change the db name and db password to:

```
	$ vim /etc/spine.conf
	DB_User cacti
	DB_Pass some_password
```

Restart crontab:

```
	$ systemctl restart cronie.service
	$ systemctl restart httpd
```


