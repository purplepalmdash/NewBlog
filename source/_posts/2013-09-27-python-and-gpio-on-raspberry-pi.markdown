---
layout: post
title: "Python and GPIO on Raspberry PI"
date: 2013-09-27 20:27
comments: true
categories: Python Linux
---
1\. 安装python-dev, 准备环境
{% codeblock %}
$ apt-get install python-dev
$ wget https://pypi.python.org/packages/source/R/RPi.GPIO/RPi.GPIO-0.5.3a.tar.gz
$ tar xzvf  RPi.GPIO-0.5.3a.tar.gz
$ python setup.py install
{% endcodeblock %}

2\. 
