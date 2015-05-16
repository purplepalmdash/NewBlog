---
layout: post
title: "Install GitLab And Gogs"
date: 2015-02-03 22:23
comments: true
categories: linux
---
For sharing the git managed codes, we need setup the online repositories, we got two options, one is for gitlab, the other is for gogs.     
### Gitlab
The reference URL is listed as in:    
[https://www.digitalocean.com/community/tutorials/how-to-set-up-gitlab-as-your-very-own-private-github-clone](https://www.digitalocean.com/community/tutorials/how-to-set-up-gitlab-as-your-very-own-private-github-clone)    
But following the tutorial you will met the problem, following records the solution:    

```
$ sudo -u git -H bundle install --deployment --without development test postgres
   Could not find modernizr-2.6.2 in any of the sources
$ cd /home/git/gitlab
$ wget http://rubygems.org/downloads/modernizr-2.6.2.gem
$ sudo gem install modernizr
$ vim Gemfile
gem "modernizr"    "2.6.2"   ===> gem "modernizr-rails",        "2.7.1"
$ vim Gemfile.lock
modernizr  (2.6.2)   ===>     modernizr-rails (2.7.1)
modernizr  (2.6.2)   ===>     modernizr-rails (= 2.7.1)
$ sudo -u git -H bundle install --deployment --without development test postgres 

```

### Gogs
We use docker for installing Gogs, the command listed as following:    

```
# sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
# sh -c "echo deb http://get.docker.io/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"
# apt-get update
# apt-get install lxc-docker
# proxychains4 docker pull codeskyblue/docker-gogs

```
This pull back the `docker-gogs` image, later you could run the gogs server via:    

```
$ mkdir /var/gogs
$ docker run -d -p 2223:22 -p 3000:3000 -v /var/gogs:/data codeskyblue/docker-gogs

```
Then visit `http://1xx.xx.xx.xxx:3000` you will got the installation webpage, simply install it.    
Everytime you run into error case, you could remove the `/var/gogs` directory and let everything happen from zero.   

### Using Gogs
Create Repository, then `git clone`, then add your own files, `git add .`, `git commit -m`, `git push origin master`, the same as you did in github.   

Some problems happens.... We changed to OpenSuse for installing.    
Remove all of the .git directory in sub-directories via following command, then problem won't happen.    

```
find ./* -name ".git" | xargs rm -rf

```
Now git push all of the changes to the remote repository and you got everything works well.    
Add the running command into `/etc/rc.local` thus the docker runs together with the system startup.    
