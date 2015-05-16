---
layout: post
title: "Flask&amp;AngularJS Blog Tips"
date: 2014-12-04 15:32
comments: true
categories: web
---
### Background
For setup the local blog which used for recording some articles, and provide the RESTful APIs for remote usage.     
The tutorial is located at:    
[http://blog.john.mayonvolcanosoftware.com/building-a-blog-using-flask-and-angularjs-part-1/](http://blog.john.mayonvolcanosoftware.com/building-a-blog-using-flask-and-angularjs-part-1/)     
### Installation of Packages
First preapare the environment using virtualenv2:    

```
$ virtualenv2 flask_blog
$ source flask_blog/bin/activate

```
Now write a requirements.txt file, under the current folder, the content is:    

```
Flask==0.10.1
Flask-Bcrypt==0.6.0
Flask-HTTPAuth==2.2.1
Flask-RESTful==0.2.12
Flask-SQLAlchemy==1.0
Flask-WTF==0.10.0
Jinja2==2.7.3
MarkupSafe==0.23
SQLAlchemy==0.9.7
SQLAlchemy-Utils==0.26.9
WTForms==2.0.1
WTForms-Alchemy==0.12.8
WTForms-Components==0.9.5
Werkzeug==0.9.6
aniso8601==0.83
decorator==3.4.0
infinity==1.3
intervals==0.3.1
itsdangerous==0.24
marshmallow==0.7.0
py-bcrypt==0.4
pytz==2014.4
six==1.7.3
validators==0.6.0
wsgiref==0.1.2

```
Use `pip install -r requirements.txt` for installing all of the packages.   

