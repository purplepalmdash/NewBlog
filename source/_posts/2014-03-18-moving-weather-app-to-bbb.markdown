---
layout: post
title: "Moving Weather App to BBB"
date: 2014-03-18 13:56
comments: true
categories: BeagleBone
---
Following is the steps for moving the weather app to BBB(BeagleBone Black)<br />
###Apache Configuration
Create the site definition file under /etc/apache2/sites-available: <br />

```
	$ cp default nanjing

```
Edit the nanjing file with the following content:

```
	$ cat nanjing
	<VirtualHost *:7778>
		ServerAdmin webmaster@localhost
	        ServerName nanjing
	        ServerAlias nanjing.weather
	
		DocumentRoot /srv/www1
		<Directory />
			Options FollowSymLinks
			AllowOverride None
		</Directory>
		<Directory /srv/www1/>
			Options Indexes FollowSymLinks MultiViews
			AllowOverride None
			Order allow,deny
			Allow from all
		</Directory>
	
		ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
		<Directory "/usr/lib/cgi-bin">
			AllowOverride None
			Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
			Order allow,deny
			Allow from all
		</Directory>
	
		ErrorLog ${APACHE_LOG_DIR}/error.log
	
		# Possible values include: debug, info, notice, warn, error, crit,
		# alert, emerg.
		LogLevel warn
	
		CustomLog ${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>

```
Then we have to edit the /etc/apache2/ports.conf file, to add the newly-added site definition file. <br />

```
	$ cat ports.conf
	NameVirtualHost *:7777
	Listen 7777
	NameVirtualHost *:7778
	Listen 7778
	NameVirtualHost *:7779
	Listen 7779
	NameVirtualHost *:7780
	Listen 7780

```
Now you already could visit the site of http://Your_Ip_Address:7777 for the nanjing weather infos. <br />
###Script Moving
Be sure following modules has been installed:< br />

```
	$ pip install django pywapi pinyin
	$ pip install BeautifulSoup

```
Add the crontab tasks:<br />

```
	0 */1 * * * python /root/code/genhtml.py
	15 */1 * * * python /root/code/genhtml_bj.py
	30 */1 * * * python /root/code/genhtml_changsha.py

```
Now the script will be run every hour at 0/15/30 minutes, enjoy it. <br />
Notice the timezone should be correctly configured:<br />

```
	$  dpkg-reconfigure tzdata
	# Choose Asia/Shanghai

```
