---
layout: post
title: "Deploy your octopress website on heroku"
date: 2013-12-14 09:48
comments: true
categories: Web
---
I've been using octopress for writing blogs for nearly half of a year. The website is hosted on my family computer, which is a arm-based machine, runs Debian Linux. But such machine can sometimes be powered off by accident. That's while I want to put my webpages onto a stable server. Most of the people put their website on github, but github may be banned in china, so I choose heroku, I think it may be much more safer.     
###Preparation
First you have to register the heroku, and then create a new App, you will got a pop-up window which contains following message:

```
	Your app, XXXX, has been Created.
	App URL:   http://XXXX.herokuapp.com/
	Git URL: git@heroku.com:XXXX.git
	Use the following code to set up your app for local development
	git clone git@heroku.com:XXXX.git -o heroku

```
You have to remember these messages, for later we will use them to upload our own website. 
###Local Modification
Clone your remote app to local directory

```
	git clone git@heroku.com:XXXX.git -o heroku
	cd heroku

```
Copy your existing octopress to local directory, be sure to remove the existing .git directory in your octopress directory.

```
	cp Source_Directory ./

```
Remove some files

```
	rm Gemfile.lock README.markdown CHANGELOG.markdown

```
Clear out the .slugignore file

```
	>.slugignore

```
Update your gemfile:

```
	source "https://rubygems.org"
	
	group :development do
	  gem 'rake', '~> 0.9'
	  gem 'jekyll', '~> 0.12'
	  gem 'rdiscount', '~> 1.6.8'
	  gem 'pygments.rb', '~> 0.3.4'
	  gem 'RedCloth', '~> 4.2.9'
	  gem 'haml', '~> 3.1.7'
	  gem 'compass', '~> 0.12.2'
	  gem 'sass', '~> 3.2'
	  gem 'sass-globbing', '~> 1.0.0'
	  gem 'rubypants', '~> 0.2.0'
	  gem 'rb-fsevent', '~> 0.9'
	  gem 'stringex', '~> 1.4.0'
	  gem 'liquid', '~> 2.3.0'
	  gem 'directory_watcher', '1.4.1'
	end
	gem 'rake', '~> 0.9'
	gem 'jekyll', '~> 0.12'
	gem 'rdiscount', '~> 1.6.8'
	gem 'pygments.rb', '~> 0.3.4'
	gem 'RedCloth', '~> 4.2.9'
	gem 'haml', '~> 3.1.7'
	gem 'compass', '~> 0.12.2'
	gem 'sass-globbing', '~> 1.0.0'
	gem 'rubypants', '~> 0.2.0'
	gem 'stringex', '~> 1.4.0'
	gem 'liquid', '~> 2.3.0'
	gem 'sinatra', '~> 1.4.2'

```
Since we use the rdiscount version is 1.6.8, when generate pages, this will cause failure, we also have to update one line in "\_config.yml":  

```
	markdown: rdiscount
	rdiscount:
	  extensions:
	    - autolink
	      #- footnotes
	    - smart

```
###Setup
Install the dependencies:

```
	bundle install

```
Also you want to notice the rvm information, for example I use 1.9.3 for octopress, then my configuration is listed as:

```
	$ cat .rvmrc
	rvm use 1.9.3
	$ cat ~/.bashrc | grep rvm
	PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

```
###Testing
Generate the website:

```
	rake generate

```
Preview the website:

```
	rake preview

```
Open http://127.0.0.1:4000 to view the preview result. 
###Deploy
Add all of the files in current directory to git

```
	git add .

```
Commit all of the changes:

```
	git commit -m 'site initialized'

```
Push your changes to heroku

```
	git push heroku master

```
View your website:

```
	heroku open

```
###Ignore some tmp files
Create a .gitignore file under the current directory

```
	.bundle
	.DS_Store
	.sass-cache
	.gist-cache
	.pygments-cache
	_deploy
	public
	sass.old
	source.old
	source/_stash
	source/stylesheets/screen.css
	vendor
	node_modules
	*~

```
Update the cache via:

```
	git rm -r --cached .
	git add .
	git commit -m "fixed untracked files"

```
Push again:

```
	git push heroku master

```
Unfortunately, the .gitignore couldn't remove public, so the final file only contains:

```
	*~

```
###Future Modification
Add new blogs:

```
	rake new_post["Your_Article_Name"]

```
Generate locally:

```
	rake generate 

```
Add changes:

```
	git commit -a 

```
Push to heroku: 

```
	git push heroku master

```
Now you have a stable and swift website on heroku, enjoy it. 
###Modify theme

```
	git clone git://github.com/lucaslew/whitespace .themes/Whitespace
	rake install['Whitespace']
	rake generate

```
More themes could be found at [https://github.com/imathis/octopress/wiki/3rd-Party-Octopress-Themes](https://github.com/imathis/octopress/wiki/3rd-Party-Octopress-Themes).     
You can preview these themes at [http://opthemes.com/](http://opthemes.com/).     
###Change Colorscheme 
Since our theme locates under the .themes/Whitespace folder, simply change the following files:    

```
$ pwd
/home/Trusty/code/octo/heroku/Tomcat/.themes/Whitespace/sass/base
[Trusty@~/code/octo/heroku/Tomcat/.themes/Whitespace/sass/base]$ cat _solarized.scss
//$solarized: dark !default;
$solarized: light !default;

```
Now your blog should have the light theme of solarized.    
