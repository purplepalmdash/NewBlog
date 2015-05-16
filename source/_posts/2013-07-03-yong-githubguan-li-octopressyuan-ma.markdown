---
layout: post
title: "用github管理octopress源码"
date: 2013-07-03 11:05
comments: true
categories: Development 
---
1\. 新建或改变某个已存在的源码仓库名为"debian_octopress"，以后可以用["https://github.com/kkkttt/debian_octopress.git"](https://github.com/kkkttt/debian_octopress.git)来访问此仓库。

2\. 配置Git:
{% codeblock %}
$ git init
$ git add README.md	# 这个文件中可以添些项目的描述文字
$ git commit -m "First Commit"
# 配置git的本地用户名和email
$ git config --global user.email "kkkttt@gmail.com"
$ git config --global user.name "Trusty"
# 将文件夹里所有内容加入到git中并提交
$ git add .
$ git commit -m "First Sourcecode Commit"
# 同步到github
$ git remote add origin https://github.com/kkkttt/debian_octopress.git
$ git push -u origin master --force
{% endcodeblock %}

3\. 删除本地文件夹并同步到Github的方法:
{% codeblock %}
$ git rm -rf public.back
$ git commit -m "remove backup directory"
$ git push origin master
{% endcodeblock %}

4\. 将本地修改同步到Github:

```
$ git commit -m "do some changes"

```
这时候会列出本地修改过的内容，运行:

```
$ git commit -a

```
修改需要提交的修改后运行下列命令后同步到Github:

```
$ git push origin master

```
