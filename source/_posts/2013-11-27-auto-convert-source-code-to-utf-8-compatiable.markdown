---
layout: post
title: "Auto convert source code to UTF-8 compatiable"
date: 2013-11-27 17:46
comments: true
categories: Linux
---
For those code files which contains gb2312 or gbk format, we can use following scripts for automatically convert them to UTF-8 conpatiable format files. 

```bash autochinese.sh
#!/bin/sh
export LANG="zh_CN.utf8"
export LC_ALL="zh_CN.utf8"
#for file in `find . -name "*.h"`
for file in `find . -name "*.c"`
do
	echo $file
	enca -L zh_CN -x UTF-8 $file
done

```
