---
layout: post
title: "Dockerize Markdown Written CV"
date: 2015-10-08 10:08:02 +0800
comments: true
categories: Linux
---
### Tips
Manually run the commands for generating the CVs.     

```
$ sudo apt-get install -y build-essential
$ sudo apt-get install -y pandoc
$ sudo apt-get install -y wkhtmltopdf 
$ sudo apt-get install xvfb
$  echo 'xvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > \
/usr/bin/wkhtmltopdf.sh
$ chmod a+x /usr/bin/wkhtmltopdf
$ chmod a+x /usr/bin/wkhtmltopdf.sh 
$ ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf
$ apt-get install -y ttf-wqy-zenhei
$ apt-get install -y git
$ apt-get install -y rubygems-integration ruby-dev
$ apt-get install -y libimage-exiftool-perl
$ gem install compass
$ gem install susy
$ git clone https://github.com/barraq/pandoc-moderncv.git
$ cd pandoc-moderncv/
$ mkdir -p cv/images/
$ vim cv/cv.md
$ gem install gempass
$ gem install 
$ make
#####$ apt-get install python-software-properties
#####$ apt-get install software-properties-common
$ vim Makefile 
   -> Change the wkpdf to wkhtmltopdf
$ make pdf
```

### Dockerfile
Write the Dockerfile like following:    

```
# Based on Ubuntu 14.04
FROM ubuntu:trusty

# Install Packages, via apt-get. 
RUN apt-get update && apt-get install -y \
	build-essential \
	pandoc \
	wkhtmltopdf \
	xvfb \
	ttf-wqy-zenhei \
	git \
	rubygems-integration \
	ruby-dev \
	libimage-exiftool-perl 

# Now Change wkhtmltopdf
RUN echo 'xvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' >
/usr/bin/wkhtmltopdf.sh
RUN chmod a+x /usr/bin/wkhtmltopdf
RUN chmod a+x /usr/bin/wkhtmltopdf.sh 
RUN ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

# Now Run gems 
RUN gem install compass
RUN gem install susy

# Git Clone the CV FrameWork from github.
RUN mkdir -p /root/Code/
RUN git clone https://github.com/barraq/pandoc-moderncv.git  /root/Code/pandoc-moderncv
RUN mkdir -p /root/Code/pandoc-moderncv/cv/images
```

Put it on github, and trigger an auto-build on dockerhub, pulling it and you could get
the well built docker image.    
