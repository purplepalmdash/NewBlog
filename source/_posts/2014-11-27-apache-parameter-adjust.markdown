---
layout: post
title: "Apache Parameter Adjust"
date: 2014-11-27 21:46
comments: true
categories: web
---
### Background
A wordpress machine runs on DigitalOcean often sudden the mysqld database lost error. 
### Analyze
This is because the memory is exhausted in DO, so first I enable the swap for machine. This method solved the problem for a long time.     
But later it seems the robots who sent the rubbish comments continue to attack the system, causing the mysqld halt again, this time, I modified the apahce2's works:     

```
$ grep -Ri MaxRequestWorkers /etc/apache2/
/etc/apache2/mods-enabled/mpm_prefork.conf:# MaxRequestWorkers: maximum number of server processes allowed to start
/etc/apache2/mods-enabled/mpm_prefork.conf:     MaxRequestWorkers         150
/etc/apache2/mods-available/mpm_prefork.conf:# MaxRequestWorkers: maximum number of server processes allowed to start
/etc/apache2/mods-available/mpm_prefork.conf:   MaxRequestWorkers         150
$ vim /etc/apache2/mods-available/mpm_prefork.conf
$ vim /etc/apache2/mods-available/mpm_worker.conf
$ vim /etc/apache2/mods-available/mpm_itk.conf
$ vim /etc/apache2/mods-available/mpm_event.conf
$ service apache2 restart

```
The vim command is changing the MaxRequestWorkers from 150 to 10, hope this will solve the problem.    
### TBD
If the mysql runs into death again, then we must limit its connection towards apache2.    

