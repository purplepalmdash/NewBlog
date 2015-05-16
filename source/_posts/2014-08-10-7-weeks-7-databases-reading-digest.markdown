---
layout: post
title: "7 Weeks 7 Databases Reading Digest"
date: 2014-08-10 11:46
comments: true
categories: database
---
This chapter will introduct postgresql.    
### Installation in ArchLinux
Install it via:    

```
# pacman -S postgresql

```
Then configure the initial configuration:    

```
# su - postgres
[postgres]$ initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'
# systemctl enable postgresql

```
Create the user:    

```
[root@Arch_Container ~]# su - postgres
[postgres@Arch_Container ~]$ createuser --interactive
Enter name of role to add: root
Shall the new role be a superuser? (y/n) y
[postgres@Arch_Container ~]$ exit
logout

```
Now using a test command for verifying your postgresql runs OK:    

```
# createdb myDatabaseName

```
### Create the Database
Create a database named book:    

```
# createdb book

```
Installing plugins cube into the database book.   

```
[root@Arch_Container postgresql]# psql -d book
psql (9.3.5)
Type "help" for help.

book=# CREATE EXTENSION cube;  
CREATE EXTENSION
book=# \q
[root@Arch_Container postgresql]# psql book -c "SELECT '1'::cube;"
 cube 
------
 (1)
(1 row)

```

