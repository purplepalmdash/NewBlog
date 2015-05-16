---
layout: post
title: "Setup Dev Env On DO"
date: 2014-11-28 10:14
comments: true
categories: Linux
---
### Prepare
Install the following packages:   

```
$ sudo apt-get install python-virtualenv
$ sudo apt-get install ruby-full ruby
$ sudo gem install rhc

```
Since DO's network is pretty good, so it's very swift for developing on it.    
### TextBlob

```
$ virtualenv venv --python=python2.7
$ . venv/bin/activate
$ pip install textblob
$ python -m textblob.download_corpora
$ pip install flask


```
