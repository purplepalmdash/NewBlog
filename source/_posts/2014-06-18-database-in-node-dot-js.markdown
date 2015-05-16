---
layout: post
title: "Database In Node.js"
date: 2014-06-18 19:43
comments: true
categories: nodejs
---
### MongoDB
Install MongoDB via:     

```
$ sudo pacman -S mongodb
$ sudo systemctl start mongodb
$ sudo systemctl enable mongodb
$ mongodb

```

Later I will cover this topic.     
### MySQL
#### Installation of MySQL
The implementation chosen by Arch Linux is called MariaDB, install it via:    

```
$ sudo pacman -S mariadb 

```
Configuration steps:    

```
$ sudo systemctl start mysqld.service
[Trusty@~]$ sudo mysql_secure_installation
/usr/bin/mysql_secure_installation: line 379: find_mysql_client: command not found

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] Y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] Y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] Y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!

```
Now you can login the mariadb via:   

```
$ mysql -u root -p
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.00 sec)

```
#### Node.js of MariaDB



### Redis
Running result:  

```
127.0.0.1:6379> SET my.key test
OK
127.0.0.1:6379> KEYS my.key
1) "my.key"
127.0.0.1:6379> VALUES my.key
(error) ERR unknown command 'VALUES'
127.0.0.1:6379> GET my.key
"test"
127.0.0.1:6379> keys *
 1) "user:jeff@amazon.com:followers"
 2) "user:jeff@amazon.com:follows"
 3) "user:bill@microsoft.com:followers"
 4) "mykey"
 5) "rq:job:b9b76e04-8bb7-4652-83e9-4453de981554"
 6) "rq:queue:default"
 7) "user:mark@facebook.com:data"
 8) "_kombu.binding.celeryev"
 9) "user:fred@fedex.com:data"
10) "user:jeff@amazon.com:data"
11) "rq:queues"
12) "user:bill@microsoft.com:follows"
13) "_kombu.binding.celery"
14) "my.key"
15) "user:bill@microsoft.com:data"
127.0.0.1:6379> KEYS my.key
1) "my.key"
127.0.0.1:6379> SET online.users 0
OK
127.0.0.1:6379> onlien.users
(error) ERR unknown command 'onlien.users'
127.0.0.1:6379> online.users
(error) ERR unknown command 'online.users'
127.0.0.1:6379> KEYS online.users
1) "online.users"
127.0.0.1:6379> GET online.users
"0"
127.0.0.1:6379> INCR online.users
(integer) 1
127.0.0.1:6379> INCR onlien.users
(integer) 1
127.0.0.1:6379> INCR online.users
(integer) 2
127.0.0.1:6379> HSET profile.1 name Guillermo
(integer) 1
127.0.0.1:6379> HGETALL profile.1
1) "name"
2) "Guillermo"
127.0.0.1:6379> HSET profile.1 last Rauch
(integer) 1
127.0.0.1:6379> HGETALL profile.1
1) "name"
2) "Guillermo"
3) "last"
4) "Rauch"
127.0.0.1:6379> HSET profile.1 programmer 1
(integer) 1
127.0.0.1:6379> HGETALL profile.1
1) "name"
2) "Guillermo"
3) "last"
4) "Rauch"
5) "programmer"
6) "1"
127.0.0.1:6379> HDEL profile.1 programmer
(integer) 1
127.0.0.1:6379> HGETALL profile.1
1) "name"
2) "Guillermo"
3) "last"
4) "Rauch"
127.0.0.1:6379> RPSH profile.1.jobs "job 1"
(error) ERR unknown command 'RPSH'
127.0.0.1:6379> RPUSH profile.1.jobs "job 1"
(integer) 1
127.0.0.1:6379> HGET profile.1
(error) ERR wrong number of arguments for 'hget' command
127.0.0.1:6379> HGETALL profile.1
1) "name"
2) "Guillermo"
3) "last"
4) "Rauch"
127.0.0.1:6379> LRANGE profile.1.jobs 0 -1
1) "job 1"
127.0.0.1:6379> 
127.0.0.1:6379> RPUSH profile.1.jobs "job 2"
(integer) 2
127.0.0.1:6379> LRANGE profile.1.jobs 0 -1
1) "job 1"
2) "job 2"
127.0.0.1:6379> RPUSH profile.1.jobs "job 3"
(integer) 3
127.0.0.1:6379> LRANGE profile.1.jobs 0 -1
1) "job 1"
2) "job 2"
3) "job 3"

```

DataSet in Redis:     

```
127.0.0.1:6379> SADD myset "a member"
(integer) 1
127.0.0.1:6379> SMEMBERS myset
1) "a member"
127.0.0.1:6379> SADD myset "a second member"
(integer) 1
127.0.0.1:6379> SMEMEBERS myset
(error) ERR unknown command 'SMEMEBERS'
127.0.0.1:6379> SMEMBERS myset
1) "a second member"
2) "a member"
127.0.0.1:6379> SREM myset "a second member"
(integer) 1
127.0.0.1:6379> SMEMBERS myset
1) "a member"

```



