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
Import from existing Octopress via:    

```
$ hugo import jekyll /home/dash/Code/NewBlog/source hugodash
Importing...
Congratulations! 720 post(s) imported!
....
```
A little tricky for changing the categories definitions:    

```
$ cd hugodash/content/post
$ vim change.sh
$ chmod 777 change.sh
$ ./change.sh
```
The content of the change.sh is listed as following:     

```
#!/bin/bash
for i in `ls ./*.markdown`
do
	# Generate the modified result, like categories: "a", "b", "c"
	replaceline=`grep -i "categories:" $i|awk
'{for(i=2;i<=NF;i++){if(i!=NF){$i="\""$i"\""","}else{$i="\""$i"\""}}}1'`
	sed -i "2s|.*|$replaceline|" $i
done
```
Then run following command:    

```
$ sed -i '2s/\(:[[:blank:]]*\)\(.*\)/\1[\2]/' *.markdown
```
Now check your categories:    

```
$ grep -i "categories:" ./ -r
./2015-03-12-maas-deploy-3.markdown:categories: ["Virtualization"]
./2016-03-31-nodemcu-and-1602i2c.markdown:categories: ["embedded"]
....
```
With this format could our markdown files be analyzied via new theme.  

```
$ cd hugodash/themes
$ git clone https://github.com/zyro/hyde-x
``` 

Preview the generated website via:     

```
$ cd hugodash
$ hugo server --theme=hyde-x
```
Now open your browser and view `http://localhost:1313`.    

### Publishment
Some work tips:    

Remove all of the fucking `codeblock` in markdown:    

```
$ sed -i -- 's|{% endcodeblock%}|\`\`\`|' *.markdown
$ sed -i -- 's|{% codeblock *.*%}|\`\`\`|' *.markdown
``` 

Remove all of the fucking backtick with language extended in markdown:    

```
$ sed -i -r -e 's|^\`\`\`.*|\`\`\`|' *.markdown
```
Now all of the syntax hightlight is OK.      
