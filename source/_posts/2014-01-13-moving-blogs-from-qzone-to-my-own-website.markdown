---
layout: post
title: "Moving blogs from Qzone to My Own website"
date: 2014-01-13 14:41
comments: true
categories: hyde qzone
---
Since I've wrote blog for more than 7 year, I decide to use my own website to hold all of the articles. So I will start a task for transferring all of the written articles to a new website. Following will be the steps for transferring.    
###Which blog system I will use
I decide to use static webiste, since the speed is much more faster than the database-based website, and it doesn't have complicated configuration. Also It's easy to backup and deploy.    
I don't want to use Octopress, because Octopress is good for recording for technical issues. And Octopress is based on ruby, while I decide to try python based static website generator.    
I will choose Hyde. The website for Hyde is located at ["http://ringce.com/hyde"](http://ringce.com/hyde), you can get the brief introduction on this website.    
###Installation
Install hyde directly from yaourt:     

```
	$ yaourt hyde

```
Or you can directly download the package from the website, and unzip it to a suitable directory, install it.     
The most simplest way is via:

```
	$ pip install hyde

```
Because my machine runs python3, while hyde currently works under python2, everytime I use hyde, just:

```
	$ workon venv2
	$ which hyde
	/home/Trusty/.virtualenvs/venv2/bin/hyde

```
It is recommended that use virtualenv to seperate the hyde environment from other python projects. Refer to ["http://hyde.github.io/install"](http://hyde.github.io/install)    
###Get Demo Site run
Create the website:

```
	$ hyde create

```
Compile all of the hyde source in the "deploy" directory:

```
	$ hyde gen

```
Run a light-weight server enable you to preview the current website
	$ hyde serve
Browser ["http://localhost:8080"](http://localhost:8080) will see the current website.     


After careful consideration, I think maybe I will try hyde later, because a better tool named pelican may fit me better.     
["http://blog.getpelican.com/"](http://blog.getpelican.com/)
