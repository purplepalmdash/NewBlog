---
layout: post
title: "Update Qzone(2)"
date: 2014-01-24 16:17
comments: true
categories: Pelican
---
Install pinyin for we want to use it for generate the title:

```
	$ pip install pinyin

```
Write a new post:

```
	$ python config_blog.py 迁移博客成功
	content/posts/2014/01/2014_01_24_qianyibokechenggong.md

```
Chinese codec:

```
	cat ~/.bashrc
	export LANG="zh_CN.UTF-8"              Or "en_US.UTF-8"
	export LC_ALL="zh_CN.UTF-8"          Or "en_US.UTF-8"

```
Write the blog:

```
	vim content/posts/2014/01/2014_01_24_qianyibokechenggong.md

```
Install BeautifulSoup

```
	pip install BeautifulSoup

```
	
	
