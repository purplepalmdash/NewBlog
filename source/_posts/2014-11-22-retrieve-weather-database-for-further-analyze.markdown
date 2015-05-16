---
layout: post
title: "Retrieve Weather Database for further analyze"
date: 2014-11-22 11:44
comments: true
categories: Apps
---
### Heroku Postgres
I wrote the weather app which holds at:     
[http://python-weather-app.herokuapp.com](http://python-weather-app.herokuapp.com)    
At around half a year it grows around 7MB, so I begin to think of how to back it and migrate to other platforms.    

Following is the steps for viewing and operation on postgres database:    

```
$ heroku login
$ heroku config
$ heroku addons | grep POSTGRES
$ heroku pg:info

```
### Backup
Install the addons of pgbackups for backing up the existing databases:    

```
$ heroku addons:add pgbackups
$ heroku pgbackups:capture

```
Use following command for store the backup locally:    

```
$ curl -o latest.dump `heroku pgbackups:url`
$ pg_restore --verbose --clean --no-acl --no-owner -h localhost -U Trusty -d weatherdb latest.dump

```
### View the data
Using following commands for viewing the data:     

```
$ psql weatherdb
weatherdb=# \dt;
          List of relations
 Schema |    Name     | Type  | Owner 
--------+-------------+-------+-------
 public | avg_weather | table | Trusty
 public | user        | table | Trusty
 public | weather     | table | Trusty
(3 rows)
weatherdb=# select * from weather;
weatherdb=# select * from avg_weather;

```
By this you could dump all of the datas which already held in this postgres database.     
