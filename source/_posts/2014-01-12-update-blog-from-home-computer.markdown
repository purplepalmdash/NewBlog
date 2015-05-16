---
layout: post
title: "Update blog from Home Computer"
date: 2014-01-12 18:51
comments: true
categories: blog
---
First , clone th repository to your home computer via:

```
	git clone git@github.com/your_name/Your_Repository

```
Second , configure everything:

```
	sudo gem install bundler
	rbenv rehash
	bundle install
	rake setup_github_pages

```
Here you will be asked to provide your accounts, enter it and continue.     
Third, do changing  the content and deploy .    

```
	rake generate
	git add . 
	git commit -am "From Home computer"
	git push origin master
	rake deploy

```
In Company computer, run:

```
	git pull origin master
	cd ./_deploy
	git pull origin master

```
