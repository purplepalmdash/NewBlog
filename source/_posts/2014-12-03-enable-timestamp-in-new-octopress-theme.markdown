---
layout: post
title: "Enable Timestamp In New Octopress Theme"
date: 2014-12-03 10:40
comments: true
categories: web
---
After installing the flattern theme of octopress, I found the post date missed. Following is the steps for catching it back.     

```
rake install['flatten']

```
Modify the following file:     

```
$ cat .themes/flatten/source/_includes/post/date.html

```
Then in `.themes/flatten/source/_layouts/post.html`, modify the following lines:    

```
    <p class="meta">
    //.....//
    </p>

```
After modification, you would see the time is displayed before the comment numbers.    
Notice, the modification is not visible in codeblocks because the embedded symbol could not be resolved thus will cause build error, so the detailed code would be only fetched from my github repository but remains blank codeblocks here in this article.    
