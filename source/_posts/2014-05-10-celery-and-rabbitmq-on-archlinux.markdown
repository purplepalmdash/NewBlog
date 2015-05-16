---
layout: post
title: "Celery and RabbitMQ on ArchLinux"
date: 2014-05-10 22:19
comments: true
categories: Linux
---
### Installation
Install and run rabbitmq server via: 

```
$ yaourt rabbitmq
$ rabbitmq-server

```
Install celery in python virtual enviroment:   

```
$ workon venv2
(venv2) $ pip install celery

```
### Run Simple Tasks
Following python file, named "tasks.py" defines two tasks:    

```
from celery import Celery

app = Celery('tasks', backend='amqp', broker='amqp://')

@app.task(ignore_result=True)
def print_hello():
    print 'hello there'

@app.task
def gen_prime(x):
    multiples = []
    results = []
    for i in xrange(2, x+1):
        if i not in multiples:
            results.append(i)
            for j in xrange(i*i, x+1, i):
                multiples.append(j)
    return results

```
Run it via:    

```
celery worker -A tasks &

```
Now in another terminal you can use python interractive window for:    

```
from tasks import print_hello
from tasks import gen_prime
print_hello()
primes = gen_prime(1000)
primes = gen_prime(50000)
# CTRL+C will stop it. 
# Access the background worker
primes = gen_prime.delay(50000)
# by the worker executing now, because we configured the backend for application
primes.ready()
False
...
True
print primes.get()

```
### Periodic Tasks
Add following lines into the tasks.py:    

```
from celery.task import periodic_task
from datetime import timedelta


@periodic_task(run_every=timedelta(minutes=1))
def print_minutes():
    print 'Hello, 1 minute reached'

@periodic_task(run_every=timedelta(seconds=3))
def every_3_seconds():
    print("Running periodic task!")

```
Now start the tasks.py via following commands:    

```
$ celery -A tasks worker --loglevel=info --beat

```
You will see Celery output "Running periodic tasks!" every 3 seconds, while every 1 minutes the "Hello, 1 minute reached" will be printed out.    

### To Be Thought
How to mirgrate it with our heroku web app ?    
The periodic_task is good for fetching pages/datas and generate the result, then store the results into the database.    

But the webapp should response to user's http request, this will be the main task. 
