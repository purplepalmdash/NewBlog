---
layout: post
title: "Octopress Tips"
date: 2014-11-25 14:39
comments: true
categories: octopress
---
### Hide AsideBar
Add following lines into your `_config.yml`:    

```
sidebar: collapse

```
Then regenerate the whole website.    
### Changing Navigation
Add "About Me" navigation:    

```
$ cat source/_includes/custom/navigation.html
<ul class="main-navigation">
  <li><a href="{{ root_url }}/">Blog</a></li>
  <li><a href="{{ root_url }}/blog/archives">Archives</a></li>
  <li><a href="{{ root_url }}/about">About Me</a></li>
</ul>

```
Add customized tags:    

```
  <li><a href="{{ root_url }}/blog/categories/linux/">Linux</a></li>
  <li><a href="{{ root_url }}/blog/categories/embedded/">Embedded</a></li>

```
### Add Customized Background
Edit the `sass/cumstom/_style.css`, change following content:   

```
html {
  background: #555555 url("/images/pagebackground.jpg");
  //background: #555555;
}

```
Now regenerate the website, ten you got the modified background website.    


