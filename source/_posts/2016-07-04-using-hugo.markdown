---
layout: post
title: "Using hugo"
date: 2016-07-04 15:36:43 +0800
comments: true
categories: Linux
---
For switching my blogging engine from octopress to hugo, following are the steps.    

### Installing GO
ArchLinux installation is:    

```
$ sudo pacman -S go
$ mkdir -p ~/go/{bin,src}
$ export GOPATH=~/go
$ export PATH="$PATH:$GOPATH/bin"
```
### Get Hugo
Hugo could be fetched directly from github, install it via:    

```
$ Notice you have to use redsocks!
$ go get -u -v github.com/spf13/hugo
$ which hugo
/home/vagrant/go/bin/hugo
```

### First Blog
Create a new site:    

```
$ hugo new site myblog
$ tree myblog
myblog/
|-- archetypes
|-- config.toml
|-- content
|-- data
|-- layouts
|-- static
`-- themes

6 directories, 1 file
```
Creat a new blog:    

```
$ hugo new post/hello.md
$ vim /home/vagrant/Code/myblog/content/post/hello.md
$ cd themes/
    git clone git@github.com:dim0627/hugo_theme_beg.git
```
Run preview of the blog:    

```
$ hugo server -w --theme=hugo_theme_beg
```
Now open browser for visiting `http://localhost:1313", you could see:    

![/images/2016_07_04_16_35_26_464x401.jpg](/images/2016_07_04_16_35_26_464x401.jpg)    

### Import From Octopress

