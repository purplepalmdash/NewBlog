---
layout: post
title: "Moving From Working PC to Own USB-Disk Based 4"
date: 2014-05-23 09:50
comments: true
categories: linux
---
### Writing Blog
I use octopress for writing blog, so this time in USB system I also want to enable it.    
Edit the `/etc/hostname` and name my computer into "USBArch", because we want to setup the id_rsa.pub in next step.    

```
$ ssh-keygen
$ cat ~/.ssh/id_rsa.pub

```
Copy the content and add it into the ["https://github.com/settings/ssh"]("https://github.com/settings/ssh"), 
Then use command `ssh -T git@github.com` to verify if you can successfully be authenticated.    

```
$ git clone git@github.com:kkkttt/debian_octopress.git
$ git clone git@github.com:kkkttt/herokublog.git

```
Now the repository is OK, but the ruby environment should be set.    

```
$ curl -L https://get.rvm.io | bash -s stable
$ rvm use 1.9.3
# log out the terminal and log in again
$ rvm rubygems latest
$ cdheroku
# Choose yes, trust the .rvmrc
$ gem install bundler
$ bundle install

```
Test the rake command:     

```
$ rake generate && rake deploy

```
OK, Then we can octopress for writing blogs.    
### WebServer
We will use xampp for webserver, because it's very convinient to configure. Login as root, then:   

```
# yaourt xampp

```
The detailed configuration steps could be viewed at:    
[http://kkkttt.github.io/blog/2014/04/23/deploy-xampp-on-archlinux/](http://kkkttt.github.io/blog/2014/04/23/deploy-xampp-on-archlinux/)

In fact here I met a very strange problem, it seems if I put the whole blog under `/home/Trusty/code`, then the browser will complains that 403, so here I make a trick in rakefile(Which is used for generating the static website), add following line in `rake generate`

```
desc "Generate jekyll site"
task :generate do
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  puts "## Generating Site with Jekyll"
  system "compass compile --css-dir #{source_dir}/stylesheets"
  system "jekyll"
  system "sudo cp -ar ./public/ /opt/ && sudo chown -R nobody /opt/public/ && sudo chgrp -R nobody /opt/public/ && sudo chmod 755 -R /opt/public/"
end

```
I don't find another method, because xampp is too complex for configuring, we needn't spend much more time on it.     


Tomorrow I will setup the other language development environment.     

