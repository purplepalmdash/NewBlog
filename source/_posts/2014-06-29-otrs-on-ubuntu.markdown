---
layout: post
title: "OTRS on Ubuntu"
date: 2014-06-29 16:00
comments: true
categories: otrs
---
First get the source code from official website, and untar it via:   

```
$ sudo tar xjvf otrs-3.3.8.tar.bz2 -C /opt/
$ cd /opt
$ sudo mv otrs-3.3.8/ otrs

```
Check the modules :    

```
$ /opt/otrs/bin/otrs.CheckModules.pl

```

Install following packages:   

```
$ sudo apt-get install liblwp-useragent-determined-perl libapache2-mod-perl2 libnet-dns-perl libnet-smtp-ssl-perl libnet-smtp-tls-butmaintained-perl libyaml-perl
$ sudo apt-get install libgd-text-perl libjson-xs-perl libpdf-api2-perl libtext-csv-xs-perl libxml-parser-perl

```

Add corresponding users and group:   

```
$ sudo useradd -d /opt/otrs/ -c 'OTRS user' otrs
$ sudo usermod -G www-data otrs

```

Create the OTRS Config Files:   

```
$ pwd
/opt/otrs
$ sudo cp Kernel/Config.pm.dist Kernel/Config.pm
$ sudo cp Kernel/Config/GenericAgent.pm.dist Kernel/Config/GenericAgent.pm

```

Check dependencies via: 

```
$ perl -cw /opt/otrs/bin/cgi-bin/index.pl
/opt/otrs/bin/cgi-bin/index.pl syntax OK
$ perl -cw /opt/otrs/bin/cgi-bin/customer.pl
/opt/otrs/bin/cgi-bin/customer.pl syntax OK
$ perl -cw /opt/otrs/bin/otrs.PostMaster.pl
/opt/otrs/bin/otrs.PostMaster.pl syntax OK

```

Set permission:    

```
$ sudo bin/otrs.SetPermissions.pl --otrs-user=otrs --web-user=www-data --otrs-group=www-data --web-group=www-data /opt/otrs

```

Now Set the conf file for apache2:    

```
$ sudo cp /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/otrs
$ sudo ln -s /etc/apache2/sites-available/otrs.conf  /etc/apache2/sites-enabled/otrs
$ sudo a2ensite otrs
$ sudo service apache2 restart

```

Now go to following URL for installation:    
[http://joggler.xxx.xxx..com/otrs/installer.pl](http://joggler.xxx.xxxx<F2>.com/otrs/installer.pl)    

After installation, restart mysql and httpd, or you will meet `OTRS - Access denied for user otrs@localhost`

Add crontab tasks via following commands:    

```
# su otrs
$ cd /opt/otrs/var/cron
$ pwd
/opt/otrs/var/cron
$ for foo in *.dist; do cp $foo `basename $foo .dist`; done
$ /opt/otrs/bin/Cron.sh start
/opt/otrs/var/cron
Cron.sh - start/stop OTRS cronjobs
Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
(using /opt/otrs) done
$ crontab -l

```

Now everything goes OK, visit [joggler.xxx.xxx..com/otrs/customer.pl](joggler.xxx.xxx.com/otrs/customer.pl) for visit the customer panel.    


Change the password for root@localhost:    

```
# ./otrs.SetPassword.pl root@localhost PLATFORM
Set password for user 'root@localhost'.
Done.

```
