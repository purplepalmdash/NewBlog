---
layout: post
title: "Virtual Node Environment For PhoneGap Development"
date: 2014-12-01 12:18
comments: true
categories: web
---
### Background
I met some tutorials which were write one or two years ago, while at that time the corresponding plugins are in an old version, so I need to find a whole "virtual" environment for developing these tutorials.     
### Install Nodeenv
"Node.js virtual environment builder" --- is the introduction for Nodeenv.    
Install it via:    

```
$ virtualenv2 venv
source venv/bin/activate
(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ 
$ pip install nodeenv
(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ which nodeenv
/home/Trusty/code/30days/PhoneGap2.9.0/venv/bin/nodeenv
(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ nodeenv --version
0.11.1

```
With this nodeenv we could setup all kinds of the dev environments.   
### Wrok With Nodeenv
Install the node.js first, this may cause long time:    

```
(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ nodeenv nodeenv 
 * Install node.js (0.10.33 
[Trusty@~/code/30days/PhoneGap2.9.0]$ du -hs *
170M    nodeenv
8.9M    venv
(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ ls
nodeenv  npm-debug.log  venv
(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ . nodeenv/bin/activate 
(nodeenv)(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ which npm
/home/Trusty/code/30days/PhoneGap2.9.0/nodeenv/bin/npm
(nodeenv)(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ which node
/home/Trusty/code/30days/PhoneGap2.9.0/nodeenv/bin/node

```
Now we could install the specified version of PhoneGap, first we should find the specified versions:    

```
$ npm view phonegap


```
This will returns the specified versions of all of the phonegap.     
Choose whichever you want.    

```
$ npm install phonegap@2.9.0-rc1-0.12.2

```
This will install the phonegap around Dec,2013, which should be fit well to the tutorial.        
Then re-activate , or manually modify the PATH as:   

```
$ export PATH=/home/Trusty/code/30days/PhoneGap2.9.0/nodeenv/bin:$PATH
(nodeenv)(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ phonegap -v
2.9.0-rc1-0.12.2

```

### Run Tutorial
#### Create Apps
Create the app via following command:   

```
(nodeenv)(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ npm config set https_proxy http://1xx.x.xx.xxx:2xxxx
(nodeenv)(venv)[Trusty@~/code/30days/PhoneGap2.9.0]$ npm config set proxy http://1xx.x.xx.xxx:2xxx
$ phonegap create audero-feed-reade com.audero.free.utility.auderofeedreader "Audero Feed Reader"

```

