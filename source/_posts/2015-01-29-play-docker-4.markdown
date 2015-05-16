---
layout: post
title: "Play Docker(4)"
date: 2015-01-29 22:41
comments: true
categories: virtualization
---
### Fig(Continue)
Met some problems in last article, so this part will continue to work on Fig, the correct configuration files are listed as following:    

```
$ ls
app.py  Dockerfile  fig.yml  requirements.txt
$ cat Dockerfile 
FROM python:2.7
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
$ cat fig.yml 
web:
  build: .
  command: python app.py
  ports:
   - "5000:5000"
  volumes:
   - .:/code
  links:
   - redis
redis:
  image: redis
$ cat requirements.txt 
flask
redis
$ cat app.py 
from flask import Flask
from redis import Redis
import os
app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hello World! I have been seen %s times.' % redis.get('hits')

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)

```
via `fig up` you could quickly build this app and let it run.    
When it running, you could use ` fig ps ` for viewing the running instance:    

```
$ sudo fig ps
      Name             Command             State              Ports       
-------------------------------------------------------------------------
figtest_redis_1    /entrypoint.sh     Up                 6379/tcp         
                   redis-server                                           
figtest_web_1      python app.py      Up                 0.0.0.0:5000->50 
                                                         00/tcp    

```
Use `sudo fig run web env` you could view all of the variables of the running instance web, or change web into redis then displaying the variables of redis.    
Use `sudo fig stop` to stop all of the running instance.     

```
$ sudo fig stop
Stopping figtest_web_1...
Stopping figtest_redis_1...

```
Use `sudo fig run web env` for displaying all of the variables of running `web`.    
### Create Django
Configuration files:    

```
$ cat Dockerfile 
FROM python:2.7
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt
ADD . /code/

$ cat fig.yml 
db:
  image: postgres
web:
  build: .
  command: python manage.py runserver 0.0.0.0:8000
  volumes:
    - .:/code
  ports:
    - "8000:8000"
  links:
    - db

$ cat requirements.txt 
Django
psycopg2


```
Via `sudo  fig run web django-admin.py startproject figexample .`    
This means, first fig will create the image, then use this image for running `django-admin.py startproject figexample`, 
Examine via different methods:    

```
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS               NAMES
1abcafc5bd59        postgres:9          "/docker-entrypoint.   4 minutes ago       Up 3 minutes        5432/tcp            django_db_1         
741b0e375c73        postgres:9          "/docker-entrypoint.   4 minutes ago       Up 4 minutes        5432/tcp            Django_db_1         
[Trusty@DashCentOS django]$ sudo fig ps
   Name                  Command               State    Ports   
---------------------------------------------------------------
django_db_1   /docker-entrypoint.sh postgres   Up      5432/tcp 

```
Change the configuration file of the django project:    

```
$ sudo vim figexample/settings.py

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'postgres',
        'USER': 'postgres',
        'HOST': 'db',
        'PORT': 5432,
    }
}

```
Save the file and run `sudo fig up`, this time your django project connects to the right postgresql server.    
Examine the running containers:    

```
$ sudo fig ps
      Name             Command             State              Ports       
-------------------------------------------------------------------------
django_db_1        /docker-           Up                 5432/tcp         
                   entrypoint.sh                                          
                   postgres                                               
django_web_1       python manage.py   Up                 0.0.0.0:8000->80 
                   runserver ...                         00/tcp           
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                    NAMES
d3c3c8bb6d0e        django_web:latest   "python manage.py ru   4 minutes ago       Up 4 minutes        0.0.0.0:8000->8000/tcp   django_web_1        
3f7b61fdd09e        postgres:9          "/docker-entrypoint.   4 minutes ago       Up 4 minutes        5432/tcp                 django_db_1        

```
### Run ASP 
Refers to:    
[http://dockerone.com/article/164](http://dockerone.com/article/164)    
The steps are listed as:    

```
$ git clone https://github.com/aspnet/Home.git
$ cd Home/
$ cd samples/HelloWeb/
$ vim Dockerfile
FROM microsoft/aspnet

COPY . /app
WORKDIR /app
RUN ["kpm", "restore"]

EXPOSE 5004
ENTRYPOINT ["k", "kestrel"]
$ sudo docker build -t myapp .
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
myapp               latest              6c0d622049ea        2 hours ago         492 MB
microsoft/aspnet    latest              1e67fe2f5a59        13 days ago         465.3 MB
$ sudo docker run -t -d -p 80:5004 myapp

```
Open your browser and visit `http://xxx.xx.xx.xxx:80` and you could found the asp based app runs.     
