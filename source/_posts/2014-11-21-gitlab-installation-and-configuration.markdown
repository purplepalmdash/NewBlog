---
layout: post
title: "GitLab Installation and Configuration"
date: 2014-11-21 18:55
comments: true
categories: Linux
---
For sharing the project and holding the status of developing Rohc project, I set this gitlab project.     
### Installation
The detailed guildeline is from following URL:     
[https://www.digitalocean.com/community/tutorials/how-to-set-up-gitlab-as-your-very-own-private-github-clone](https://www.digitalocean.com/community/tutorials/how-to-set-up-gitlab-as-your-very-own-private-github-clone)     
But have some modifications.     
### Modification
Write permission problem:    

```
ERROR:  While executing gem ... (Gem::FilePermissionError)
You don't have write permissions for the /usr/local/rvm/gems/ruby

```
Solved via:    

```
$ sudo chmod -R 777 /usr/local/bin
$ sudo chmod -R 777 /usr/local/rvm

```
We met modernizr missing problem, do following for avoiding this:    

```
$ sudo wget http://rubygems.org/downloads/modernizr-2.6.2.gem
$ sudo -u git -H gem install modernizr

```
Also you have to modify following modules in Gemfile and Gemfile.lock:    

```
in Gemfile, line 164, change "modernizr", "2.6.2" to "modernizr-rails", "2.7.1"
in Gemfile.lock, line 292, change modernizr (2.6.2) to modernizr-rails (2.7.1)
in Gemfile.lock, line 626, change modernizr (= 2.6.2) to modernizr-rails (= 2.7.1)

```
Then run:     

```
sudo -u git -H bundle install --deployment --without development test postgres aws

```
You could continue with your settings.    

After setting we may met smtp configuration problem, simply modify the following configuration file:     

```
$ pwd
/home/git/gitlab
$ cat ./config/environments/production.rb
  # config.action_mailer.delivery_method = :sendmail
  # # Defaults to:
  # # # config.action_mailer.sendmail_settings = {
  # # #   location: '/usr/sbin/sendmail',
  # # #   arguments: '-i -t'
  # # # }
  # config.action_mailer.perform_deliveries = true
  # config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      :address => 'nwsxxx.xxx.xxxxxx.com',
      :port => 25,
      :domain => '1xx.2xx.xxx.xxx'
      #:domain => '1xx.2xx.xxx.xxx',
      #:authentication => :plain,
      #:user_name => 'gitlab@yourserver.com',
      #:password => 'yourPassword',
      #:enable_starttls_auto => true
  }

```
### Existing problem
The smtp method won't send out the letters to the external users, I mean the email could only be used intranet not internet.     

### Git command
Using different branches for holding code:    

```
[root@Linux01 twal]# pwd
/root/code/rohctest/twal
[root@Linux01 twal]# git branch
  Dev_For_ECCMU/ECCM2
  DirectoryBasedTestcases
  eccm2
* master
[root@Linux01 twal]# git checkout eccm2
Switched to branch 'eccm2'
[root@Linux01 twal]# git branch
  Dev_For_ECCMU/ECCM2
  DirectoryBasedTestcases
* eccm2
  master

```

So now you are in the eccm2 branch, do:

```
$ export TUT_CFG_FILE=/root/code/gencfg_114/wal_tuni_ipconn53.cfg
$ ./rohcFun11.py

```
If you want to test on eccmu, simply brach back to master via:

```
$ git checkout master
$ export TUT_CFG_FILE=/root/code/gencfg_117/wal_tuni_ipconn53.cfg
$ ./rohcFun11.py

```
Push all of the branches to the remote repository:    

```
$ git push --all

```
