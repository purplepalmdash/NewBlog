---
layout: post
title: "tessera how-to"
date: 2015-12-08 10:26:48 +0800
comments: true
categories: Virtualization
---
### Installation
Installation steps are listed as following:    

```
# apt-get install -y python-virtualenv
# git clone git@github.com:urbanairship/tessera.git
# cd tessera
# virtualenv .
# . bin/activate
# cd tessera-server/
# pip install -r requirements.txt
# pip install -r dev-requirements.txt
# cd ../tessera-frontend
# apt-get install -y npm
# npm install -g grunt-cli
# npm install
# ln -s /usr/bin/nodejs /usr/bin/node
# grunt
# which inv
/root/Code/second/tessera/bin/inv
```

### Start 
Start the service via:     

```
# cd /root/Code/second/tessera/tessera-server/
# inv db.init
# inv run &
# inv json.import 'demo/*'
```

Open the browser and visit `http://localhost:5000`, you could see the tessera's web
front.   

![/images/2015_12_08_11_42_52_998x527.jpg](/images/2015_12_08_11_42_52_998x527.jpg)   

### Import Graphite Data

```
(tessera)root@monitorserver:~/Code/second/tessera/tessera-server# vim tessera/config.py 
root@monitorserver:~/Code/second/tessera# cat tessera-server/tessera/config.py
GRAPHITE_URL               = 'http://192.168.10.192'
# inv graphite.import
``` 

Now you could see the imported graphite data.    
