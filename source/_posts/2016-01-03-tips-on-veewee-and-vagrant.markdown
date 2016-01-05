---
layout: post
title: "Tips on Veewee and Vagrant"
date: 2016-01-03 15:56:09 +0800
comments: true
categories: linux
---
### Install Veewee
First you should get rvm avaiable, then use rvm for install ruby-2.2.1:    
Note: you should import gpg signature via commandline.    

```
$ proxychains4 curl -k --insecure  -L https://get.rvm.io | bash -s stable --ruby
$ proxychains4 rvm install ruby-2.2.1 
```

Install the veewee via:     

```
$ proxychains4 gem install bundler
$ git clone https://github.com/jedi4ever/veewee.git
$ cd veewee
$ proxychains4 gem install i18n -v '0.7.0'
$ proxychains4 bundle install
```

After installation createing an alias for quickly refers to veewee:     

```
$ alias veewee="bundle exec veewee version"
```
Bug-fix: for adding `net/scp` in the Gemfile:    

```
$ vim Gemfile
.......
+ gem "net-scp"
gemspec
```

### Install Vagrant
Since the vagrant provided via Ubuntu14.04 is pretty old, we have to download
it from vagrant's official website and dpkg install it.   

Install veewee plugins:    

```
$ proxychains4 vagrant plugin install veewee
``` 

### Create new definition
Create new definition via:    

```
$ veewee vbox define awesome-ubuntu-server ubuntu-14.04-server-amd64
The basebox 'awesome-ubuntu-server' has been successfully created from the template
'ubuntu-14.04-server-amd64'
You can now edit the definition files stored in
/home/dash/Code/veewee/definitions/awesome-ubuntu-server or build the box with:
veewee vbox build 'awesome-ubuntu-server' --workdir=/home/dash/Code/veewee
```

Now start building:    

```
$ veewee vbox build awesome-ubuntu-server
```

### Speed-up Building
Use Local Installation ISO:    

```
$ vim definitions/awesome-ubuntu-server/definition.rb
+   :iso_src => "http://192.168.0.79/iso/ubuntu-14.04-server-amd64.iso",
$ vim ./lib/veewee/provider/virtualbox/box/helper/guest_additions.rb
+          url="http://192.168.0.79/iso/#{isofile}"
```
Force ruby for using local installation:    

```
$ vim definitions/awesome-ubuntu-server/ruby.sh
......
wget http://192.168.0.79/iso/veewee/ruby-$RUBY_VERSION.tar.gz
tar xvzf ruby-$RUBY_VERSION.tar.gz
......
RUBYGEMS_VERSION=2.1.10
wget http://192.168.0.79/iso/veewee/rubygems-$RUBYGEMS_VERSION.tgz
```

### File Position
The generated image position is listed in:    

```
➜  awesome-ubuntu-server  pwd
/home/dash/VirtualBox VMs/awesome-ubuntu-server
➜  awesome-ubuntu-server  du -hs *
3.2G    awesome-ubuntu-server1.vdi
8.0K    awesome-ubuntu-server.vbox
8.0K    awesome-ubuntu-server.vbox-prev
68K     Logs
```

