---
layout: post
title: "Use Xapian for creating a local search engine"
date: 2013-10-25 14:22
comments: true
categories: Linux Web
---
###Install Xapian-core
Xapian-core is the Xapian library itself. We have to install it from source-code

```
	$ wget http://oligarchy.co.uk/xapian/1.2.15/xapian-core-1.2.15.tar.gz
	$ tar xzvf xapian-core-1.2.15.tar.gz && cd xapian-core-1.2.15/
	$ ./configure --prefix=/usr/local && make && make install
```

###Install Omega
Omega utilities is an application built on Xapianm, consisting of indexers and a CGI search frontend. 

```
	$ wget http://oligarchy.co.uk/xapian/1.3.1/xapian-omega-1.3.1.tar.gz
	$ tar xzvf xapian-omega-1.3.1.tar.gz &&  cd xapian-omega-1.3.1/
	$ ./configure --prefix=/usr/local && make && make install
```

###Configure the CGI for apache
Change the "ScriptAlias /cgi-bin/ "/usr/lib/cgi-bin/"", so the httpd knows cgi binaries is put in the /usr/lib/cgi-bin directory. Then we have to copy the omega library to the /usr/lib/cgi-bin/:   

```
	$ cd xapian-omega-1.3.1/
	$ cp omega /usr/lib/cgi-bin/omega.cgi
	$ cp omega.conf /usr/lib/cgi-bin/
	$ chmod 755 /usr/lib/cgi-bin/omega.cgi
```

The Configuration file /usr/lib/cgi-bin/omega.conf should looks like this:

```
	database_dir /var/lib/omega/data
	template_dir /var/lib/omega/templates
	log_dir /var/log/omega
	cdb_dir /var/lib/omega/cdb
```

Copy the templates to the new directory:  

```
	$ cd xapian-omega-1.3.1/
	$ cp -ar /templates/* /var/lib/omega/templates/
	$ mkdir -p /var/lib/omega/data/default
	$ chmod -R 644 /var/lib/omega/data/default
```

Generate the database file:

```
	$ sudo /usr/local/bin/omindex --db /var/lib/omega/data/default --url / /home/Trusty/code/octo/debian_octopress/public/
```

###Result
Restart the httpd daemon:  

```
	$ systemctl restart httpd
```

Browser http://localhost/cgi-bin/omega.cgi you will see the following picture:   

![/images/xapian.jpg](/images/xapian.jpg)   
 
![Alt text](/images/xapian.jpg "xapian")

