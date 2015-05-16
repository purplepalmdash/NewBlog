---
layout: post
title: "Compare pkg content"
date: 2014-09-03 19:13
comments: true
categories: Linux
---
Use dpkg for reading the content and compare with the official ones:    

```
 dpkg -c ../../xxxxx_name.deb | awk '{print $3 $6}' | sort -n

```
Scripts for listing all of the content in the directory:    

```
for i in `ls *.deb`
do
    echo $i
    dpkg -c $i
done

```

