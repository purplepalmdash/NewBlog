---
layout: post
title: "Re-Orgnize Blog"
date: 2015-05-16 10:53
comments: true
categories: 
---
Since my last blog touched something special, I have to delete the whole repository and re-orgnize the structure again. This time I also use Octopress, but the version has been upgraded to the 3.0, this article records the steps.    
### Github Account
Register a new account, and verrify the email, add your own ssh key, test it via ssh -T git@github.com
### Repository
Get the latest repository via:    

```
$ git clone https://github.com/imathis/octopress.git

```
Configuration of the konsole, enable the `zsh -l` at the login shell.   Settings-> Edit Current Profile-> General -> Command(/bin/zsh -l)     

```
$ rvm use 1.9.3
$ ruby --version
ruby 1.9.3p547 (2014-05-14 revision 45962) [x86_64-linux]
$ gem install bundler
$ vim Gemfile
#source "https://rubygems.org"
source "http://mirrors.aliyun.com/rubygems/"
$ bundle install
$ rake install

```
Now the basic configuration of the repository has been added.   
### Plugins
For adding videos:    

```
$ git clone https://github.com/manojlds/octopress-plugins.git
$ cd octopress
$ cd plugins
$ cp ../../octopress-plugins/youtube.rb ./

```

### Encryption

