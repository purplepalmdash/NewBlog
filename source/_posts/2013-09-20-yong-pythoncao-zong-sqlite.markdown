---
layout: post
title: "用python操纵Sqlite3"
date: 2013-09-20 15:50
comments: true
categories: Python Sqlite3
---
1\. 在命令行下使用sqlite3创建数据库, 运行完以下命令后，在本地目录会生成一个weather.db文件，由于我们什么都没有做，所以这个数据库现在是空的。
{% codeblock %}
$ sqlite3 weather.db
SQLite version 3.8.0.2 2013-09-03 17:11:13
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .tables
sqlite> .exit
[Trusty@DashArch weather]$ ls
weather.db
{% endcodeblock %}
2\. 

