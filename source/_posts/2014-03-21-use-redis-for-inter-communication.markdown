---
layout: post
title: "Use Redis For Inter-Communication"
date: 2014-03-21 15:55
comments: true
categories: Redis
---
###Play With Redis
On ArchLinux, we install redis via:<br />

```
	$ sudo pacman -S redis
```
Enalbe and start the redis.service:<br />

```
	$ sudo systemctl enable redis.service
	$ sudo systemctl start redis.service
	$ ps -ef | grep redis
	redis     7609     1  0 16:03 ?        00:00:00 /usr/bin/redis-server 127.0.0.1:6379
```
Play with redis:<br />

```
	[Trusty@DashArch queue]$ redis-cli 
	127.0.0.1:6379> set name leezk
	OK
	127.0.0.1:6379> get name
	"leezk"
	127.0.0.1:6379> del name
	(integer) 1
	127.0.0.1:6379> exists name
	(integer) 0
	127.0.0.1:6379> exit
```
###RQ: Simple Job Queue For Python
Install redis and rq:<br />

```
	$ sudo pip2 install redis
	$ sudo pip2 install rq
```
Install requests for debugging(Not related with RQ and Redis):<br />

```
	$ sudo pip2 install requests
```

Use following file for RedisQueue:<br />

```py RedisQueue.py
import redis

class RedisQueue(object):
    """Simple Queue with Redis Backend"""
    def __init__(self, name, namespace='queue', **redis_kwargs):
        """The default connection parameters are: host='localhost', port=6379, db=0"""
        self.__db= redis.Redis(**redis_kwargs)
        self.key = '%s:%s' %(namespace, name)

    def qsize(self):
        """Return the approximate size of the queue."""
        return self.__db.llen(self.key)

    def empty(self):
        """Return True if the queue is empty, False otherwise."""
        return self.qsize() == 0

    def put(self, item):
        """Put item into the queue."""
        self.__db.rpush(self.key, item)

    def get(self, block=True, timeout=None):
        """Remove and return an item from the queue. 

        If optional args block is true and timeout is None (the default), block
        if necessary until an item is available."""
        if block:
            item = self.__db.blpop(self.key, timeout=timeout)
        else:
            item = self.__db.lpop(self.key)

        if item:
            item = item[1]
        return item

    def get_nowait(self):
        """Equivalent to get(False)."""
        return self.get(False)


```
Testing the RedisQueue with following:<br />
Put something into the RedisQueue:<br />

```
	>>> from RedisQueue import RedisQueue
	>>> q = RedisQueue('test')
	>>> q.put('hello World!')
```
Fetch something from the RedisQueue:<br />

```
	>>> from RedisQueue import RedisQueue
	>>> q = RedisQueue('test')
	>>> q.get()
	'hello World!'
```
###Rewrite Dictionary Program

