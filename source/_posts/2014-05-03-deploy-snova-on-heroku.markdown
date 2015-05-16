---
layout: post
title: "Deploy Snova On Heroku"
date: 2014-05-03 11:55
comments: true
categories: 
---
###Setting Account
First you have to install heroku deploy tool via:    

```
$ heroku plugins:install https://github.com/heroku/heroku-deploy 

```
Then login and create the app:    

```
$ heroku login
Enter your Heroku credentials.
Email: xxx@gmail.com
Password (typing will be hidden): 
Authentication failed.
$ $ heroku apps:create xxx
Creating xxx... done, stack is cedar
http://xxx.herokuapp.com/ | git@heroku.com:xxx.git

```
###Source Code Preparation
Download the source code from [https://code.google.com/p/snova/](https://code.google.com/p/snova/), here you need to cross the Greatwall.    

```
wget https://code.google.com/p/snova/downloads/detail?name=snova-c4-java-server-0.22.0.war
wget https://code.google.com/p/snova/downloads/detail?name=snova-0.22.0.zip&can=2&q=

```
Here, we use the java version of the snova.    
###Deploy Apps On Heroku 
Now begin to deploy your Snova: 

```
heroku deploy:war --war ./snova-c4-java-server-0.22.0.war --app "Your_App_Name" 

```
###Configure Client 
unzip the snova-0.22.0.zip and configure it:    

```
unzip snova-0.22.0.zip
cd snova-0.22.0
vim conf/snova.conf
[C4]
Enable=1
WorkerNode[0]=Your_App_Name.herokuapp.com 

```
You can create a shortcut for calling the Snova, add following line into ~/.bashrc:  

```
alias snova='/home/Trusty/code/gfw/snova/snova-0.22.0/bin/start.sh'

```
###Configure Browser
The proxy address is 127.0.0.1, the port is 48100 or 48102. 
