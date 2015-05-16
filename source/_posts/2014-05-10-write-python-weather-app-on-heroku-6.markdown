---
layout: post
title: "Write Python Weather APP on Heroku(6)"
date: 2014-05-10 16:46
comments: true
categories: python
---
### Risk
On Google App Engine it's very convinient to setup a crontab task, while in heroku setting up a crontab task will occupy the material, thus will use another dyno, each dyno will cost $30/month. For avoiding this, we will re-design our Weather App.     
Following is the detailed explanation on heroku's dyno:    
Heroku allows you to run one free dyno (or actually they give you 720 free dyno hours per month, which corresponds to one dyno constantly running). This means that if you choose to run one web dyno and one worker dyno (celery in this case), you'll be charged for 720 dyno hours. However, if you have a very small project, or your're working on a project that hasn't been released yet, you can avoid this cost.    
A heroku dyno is like a process, and in this process you can actually spawn new processes, as long as you stay within the limit of 512 mb ram (the process also only has one CPU core). Heroku suggests that you use foreman when you run your application on your local machine, but you can actually use foreman on heroku, in order to run multiple processes in a single dyno.    
On Heroku, we don’t have physical machines; in fact there isn’t the concept of “machine” at all. Instead, Heroku has Dynos, which are described as “lightweight containers” for UNIX processes. From their documentation:

[A Dyno] can run any command available in its default environment combined with your app’s slug   
### Solution
Celery[www.celeryproject.org](www.celeryproject.org)    
or    
Honcho[https://github.com/nickstenning/honcho](https://github.com/nickstenning/honcho)    
We will try Honcho first, because it's based on python, so won't affect our code format.    

#### Celery Way
Install redis and celery: 

```
pip install redis celery

```
Remember to use `pip freeze` to update the requirement.txt file.     
We should also enable the RedisToGo plugin, install it via CLI:    

```
$ heroku addons:add rediscloud

```
If you don't have a credit card, then your installation of plugin will be fail. We will register an account on [www.redislabs.com](www.redislabs.com/), then we will continue our setting.  ]

```
heroku config:set REDISCLOUD_URL="http://Resouce_Name:Redis_Passwod@pub-redis-xxxx.xxx.xxx..garantiadata.com:1xxx3"

```
Your heroku app will restart, then we can test this redis database via following commands:    

```
$ heroku run python
Running `python` attached to terminal... up, run.8246
Python 2.7.6 (default, Jan 16 2014, 02:39:37) 
[GCC 4.4.3] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import os
>>> import urlparse
>>> import redis
>>> url = urlparse.urlparse(os.environ.get('REDISCLOUD_URL'))
>>> r = redis.Redis(host=url.hostname, port=url.port, password=url.password)
>>> r.set('foo','bar')
True
>>> r.get('foo')
'bar'

```

An Article of using celery is right after this article, so we end this article and in next one we will re-design the web app to fit the celery way.     
