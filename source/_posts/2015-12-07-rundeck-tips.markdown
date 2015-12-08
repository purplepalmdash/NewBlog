---
layout: post
title: "Rundeck Tips"
date: 2015-12-07 11:58:55 +0800
comments: true
categories: linux
---
### Installation
Install the rundeck under CentOS 7:    

```
# rpm -Uvh http://repo.rundeck.org/latest.rpm
# yum install rundeck
```

### Configuration
Configure some properties:    

```
# vim /etc/rundeck/framework.properties
framework.server.name = 192.168.0.79
framework.server.hostname = 192.168.0.79
framework.server.port = 4440
framework.server.url = http://192.168.0.79:4440
# vim /etc/rundeck/rundeck-config.properties
grails.serverURL=http://192.168.0.79:4440 
```

Start the service:    

```
# service rundeckd start
Starting rundeckd (via systemctl):                         [  OK  ]
```
You could check the status via `# systemctl status rundeckd`.    

Now visit the server via http://192.168.0.79:4440, username/password are all `admin`, you should see following image:    

![/images/2015_12_07_12_11_49_956x398.jpg](/images/2015_12_07_12_11_49_956x398.jpg)    

Hint for creating project:    

![/images/2015_12_07_12_13_56_694x389.jpg](/images/2015_12_07_12_13_56_694x389.jpg)    

### Run
Run command locally for creating an command based job.     

In case of sudo requires a tty for executing the command:    

```
# visudo
+ # Defaults    requiretty
+ rundeck ALL=(ALL)   NOPASSWD: ALL 
``` 

### Reference
[http://www.tuicool.com/articles/zuI3ua](http://www.tuicool.com/articles/zuI3ua)    

[http://www.oschina.net/p/rundeck](http://www.oschina.net/p/rundeck)    

[http://gunner.me/archives/488](http://gunner.me/archives/488)    

