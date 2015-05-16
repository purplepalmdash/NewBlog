---
layout: post
title: "Write Python Weather APP on Heroku"
date: 2014-05-09 14:40
comments: true
categories: python
---
### Accounting Setting
First you should have heroku accounting, then create an app on heroku, write down its repository information, mine is listed as following:    

```
Your app, python-weather-app, has been created.    
App URL:    
http://python-weather-app.herokuapp.com/   
Git URL:    
git@heroku.com:python-weather-app.git      
Use the following code to set up your app for local development:    

```
git clone git@heroku.com:python-weather-app.git -o heroku

```
Suggested next steps    
 Get started with Heroku.   
 Add some collaborators.    
 Check out some of our great add-ons.

```
Before you continue, make sure you have install heroku tools:    

```
$ yaourt -S heroku-toolbelt

```
### Create HelloWorld App
Use github for recording all of the source code.  
Create a repository on github, mine is at "git@github.com:kkkttt/herokuWeatherApp.git", then:    

```  
$ pwd
/home/Trusty/code/herokuWeatherApp
$ touch README.md
$ git init
$ git add README.md
$ git commit -m "first commit"
$ git remote add origin git@github.com:kkkttt/herokuWeatherApp.git
$ git push -u origin master

```
First login with heroku:    

```
$ heroku login
Enter your Heroku credentials.
Email: xxxxxx@gmail.com
Password (typing will be hidden): 
Authentication successful.

```
Now create the folder which holds WeatherApp and create the venv, later we will use virtual environment for working:    

```
$ virtualenv2 venv
New python executable in venv/bin/python2
Also creating executable in venv/bin/python
Installing setuptools, pip...done.
$ source venv/bin/activate
(venv) $ pip install Flask gunicorn

```
Now we write a very simple python file, name it "hello.py":    

```
import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello World!'

```
Create a Procfile in the root directory which holds our own App:   

```
$ cat Procfile 
web: gunicorn hello:app

```
Use foreman for preview the web app:    

```
$ foreman start
14:53:37 web.1  | started with pid 30946
14:53:37 web.1  | 2014-05-09 14:53:37 [30946] [INFO] Starting gunicorn 18.0
14:53:37 web.1  | 2014-05-09 14:53:37 [30946] [INFO] Listening at: http://0.0.0.0:5000 (30946)
....

```
Open your browser and visit "http://127.0.0.1:5000" and you can see "Hello World" is in browser.    
Now make the requirement file in the root folder:    

```
$ pip freeze>requirements.txt
(venv)$ cat requirements.txt 
Flask==0.10.1
Jinja2==2.7.2
MarkupSafe==0.23
Werkzeug==0.9.4
gunicorn==18.0
itsdangerous==0.24
wsgiref==0.1.2

```
### Deploy It To Heroku
We have to ignore the temp files, so we add following into our .gitignores file: 

```
$ cat .gitignore
*~
*.pyc
venv/

```
We add the app into the heroku:   

```
$ heroku git:remote -a python-weather-app
Git remote heroku added
(venv)$ git remote -v
heroku	git@heroku.com:python-weather-app.git (fetch)
heroku	git@heroku.com:python-weather-app.git (push)
origin	git@github.com:kkkttt/herokuWeatherApp.git (fetch)
origin	git@github.com:kkkttt/herokuWeatherApp.git (push)

```
Deploy:    

```
$ git push heroku master

```
Now open your browser and visit "http://python-weather-app.herokuapp.com/" you will see the webpage displays "Hello World!". 
