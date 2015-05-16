---
layout: post
title: "Tips on 30Days30Skills(1)"
date: 2014-11-23 17:37
comments: true
categories: web
---
### Day 3 - Flask
First install the virtualenv environment via:     

```
$ brew install pyenv-virtualenv

```
Create the 2.7 virtualenv of python, first you have to install 2.7(before you could use list for listing all of the aviable versions), then use following command for creating the 2.7 virtualenv for developing flask:   

```
$ eval "$(pyenv init -)"
$ pyenv install --list
$ pyenv install 2.7
$ pyenv virtualenv 2.7 venv_For_Flask_2.7
$ pyenv versions
$ pyenv activate venv_For_Flask_2.7
(venv_For_Flask_2.7)Yosemite:~ Trusty$ pip install flask

```
Git clone the project from github, then install via the requirement.txt:     

```
$ git clone https://github.com/shekhargulati/instant-flask-web-development-book-app.git scheduleapp
$ cd scheduleapp/
$ pip install -r requirements.txt
$ python manage.py create_tables
$ python manage.py runserver

```
Now you could  visit the http://localhost:5000 for viewing the result.   

Since you created this appliation, so it's very easy for deploying it on Openshift.    

Install rhc on Mac, before install, make sure your network is configured OK(mine is set the proxy via ):     

```
sudo gem install rhc

```
Run following command for setup the rhc on your own machine:    

```
rhc setup

```
Deploy the app via following command;    

```
MacBook-Air-di-Trusty:schedulingapp Trusty$ rhc create-app schedapp python-2.7 postgresql-9.2 --from-code=https://github.com/shekhargulati/schedapp-openshift.git

```
After deployment, the following app will be available for accessing:    
[http://schedapp-kkkttt.rhcloud.com/](http://schedapp-kkkttt.rhcloud.com/)     


### Day 4 - PredictionIO
Install Vagrant and its plug-ins:    

```
$ sudo pacman -S vagrant
$ vagrant plugin install vagrant-login vagrant-share

```
Download the latest PredictionIO-Vagrant:    

```
$ wget https://github.com/PredictionIO/PredictionIO-Vagrant/archive/v0.8.2.tar.gz

```
For working under proxy, install vagrant-proxyconf plugins:    

```
$ vagrant plugin install vagrant-proxyconf

```
Add following to

```
  # Proxy Setting
  config.proxy.http = "http://1xx.x.xx.xxx:2xxx"
  config.proxy.https = "http://1xx.x.xx.xxx:2xxx"
  config.proxy.no_proxy = "localhost,127.0.0.1"
end

```
Following the tutorial may cause error, so I follow the guideline from the official website:     

```
$ vagrant box add precise64 http://files.vagrantup.com/precise64.box

```
Then go the downloaded folder and start the vagrant:    

```
$ pwd
/media/y/Vagrant/PredictionIO/PredictionIO-Vagrant-0.8.2
$ vagrant up

```
Now login into the vagrant machine and add the new user:    

```
$ vagrant ssh
vagrant@precise64:~$ /opt/PredictionIO/bin/users 
Warning: JAVA_HOME environment variable is not set.

PredictionIO CLI User Management

1 - Add a new user
2 - Update email of an existing user
3 - Change password of an existing user
Please enter a choice (1-3): 1
Adding a new user
Email: kkkttt@gmail.com
Password: ********
Retype password: ********
First name: Trusty
Last name: mao
User added

```
For settingup the vagrant in opensuse:    

```
$ wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.5_x86_64.rpm
$ rpm -ivh vagrant_1.6.5_x86_64.rpm
$ which vagrant
/usr/bin/vagrant 
$ vagrant box add precise64 http://files.vagrantup.com/precise64.box
$ vagrant plugin install vagrant-proxyconf

```

Previous version won't create the user successfully, then I switch to 0.6.5, thus everything goes OK.   

After Added the users, you could visit the webpage at "http://localhost:9000"       

Add the application named "blog-recommender" in the webpage.     
#### Eclipse Setup
The Url for input in the elipse is:     
[http://download.eclipse.org/technology/m2e/releases](http://download.eclipse.org/technology/m2e/releases)    

Install the m2eclipse via following methods:     
![/images/eclipseplugins_m2eclipse1.jpg](/images/eclipseplugins_m2eclipse1.jpg)
Then:   
![/images/eclipseplugins_m2eclipse2.jpg](/images/eclipseplugins_m2eclipse2.jpg)


Create project via:    
![/images/createmaven.jpg](/images/createmaven.jpg)    
You will encounter error, simply download the catelog file from:    
[http://repo1.maven.org/maven2/archetype-catalog.xml](http://repo1.maven.org/maven2/archetype-catalog.xml)_    
Then add the catalog file like following:    
![/images/addcatalog.jpg](/images/addcatalog.jpg)     
Now re-create the project :     
![/images/maven_archetype_quickstart.jpg](/images/maven_archetype_quickstart.jpg)    

But this won't solve the problem, we have to install maven manually in ArchLinux:     

```
$ sudo pacman -S maven
$ # fetch the files from: 
	http://mirrors.ibiblio.org/pub/mirrors/maven2/org/apache/maven/archetypes/maven-archetype-quickstart/
	maven-archetype-quickstart-1.1.jar
$ mvn install:install-file -DgroupId=org.apache.maven.archetypes -DartifactId=maven-archetype-webapp -Dversion=1.0 -Dpackaging=jar -Dfile=maven-archetype-weba
pp-1.0.jar

```
Now re-new the configuration.    

This method is not OK, finally I downloaded the Eclipse Kepler and place it under the `/media/y/Vagrant/eclipse`, this time it could create the project successfully, but it failed when creating classes, complaing that missing some dependencies.   

