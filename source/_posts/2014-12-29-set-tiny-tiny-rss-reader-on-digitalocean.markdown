---
layout: post
title: "Set Tiny Tiny Rss Reader on DigitalOcean"
date: 2014-12-29 10:00
comments: true
categories: web
---
Since Google Reader has been closed, many guys cannot find suitable Rss Reader for personal use. Following is a simple guildeline for setting up the Tiny Tiny Rss Reader on DigitalOcean, using docker, it's pretty simple for setting up .     
### Container Setup
Build two containers:    

```
cd code
mkdir TinyTinyRss
cd TinyTinyRss/
git clone https://github.com/clue/docker-ttrss.git
cd docker-ttrss/
docker run -d --name ttrssdb nornagon/postgres
docker run -d --link ttrssdb:db -p 8078:80 clue/ttrss

```
ttrssdb is the dababase name for postgres, while the clue/ttrss is the tinytinyRss Webapp.      
### Effect
Visit the following URL:    
`http://Your_IP:8078`    
Then you would see the following picture:    
![/images/tinytinyrss.jpg](/images/tinytinyrss.jpg)    
The default username/password is admin/123456

### Commit Changes
List the running images and commit the changes to the new container:     

```
~# docker ps
700c82aa344b        clue/ttrss:latest          /bin/sh -c 'php /con   3 days ago          Up 3 days           0.0.0.0:8078->80/tcp                                             dreamy_davinci 
# docker commit 700c82aa344b wmz_tinyrss
c85a9d1a15b18685ffc3441e18f327059928aca623a39b36780184676f6d0921

```
Now we could stop the running container and changes the listening port.    

```
# docker stop 700c82aa344b
700c82aa344b
# docker run -d --link ttrssdb:db -p 8080:80 wmz_tinyrss
f378197f7a048a02550e9152a44929628cc77ce61ea1c9e223fc3c7a46fb9bb5

```
Now the tinyRss listens on 8080 port.    
