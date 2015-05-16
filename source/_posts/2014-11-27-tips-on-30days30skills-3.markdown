---
layout: post
title: "Tips on 30Days30Skills(3)"
date: 2014-11-27 15:46
comments: true
categories: web
---
### Day 7 - GruntJS(2)
#### GruntJS Markdown Plugin
First download the source file:    

```
$ git clone https://github.com/shekhargulati/day7-gruntjs-livereload-example.git
$ cd day7-gruntjs-livereload-example
$ sudo npm install -g grunt
$ grunt $ cd day7-gruntjs-livereload-example
$ sudo npm install -g grunt
$ npm init
$ npm install grunt
$ sudo npm install grunt-contrib-uglify grunt-markdown grunt-contrib-watch -g
$ grunt
>> Local Npm module "grunt-contrib-watch" not found. Is it installed?

Running "uglify:build" (uglify) task
>> 1 file created.

Running "markdown:all" (markdown) task
File "docs/html/day1.html" created.

Done, without errors.

```


```
	<div id="main" class="container">
		<%=content%>
	</div>

```
After grunt, the generated html file is listed as :    

```
	<div id="main" class="container">
		<p>Today is the fourth day of my challenge to learn 30 technologies in 30 days. So far I am enjoying it and getting good response from fellow developers. I am more than motivated to do it for full 30 days. In this blog, I will cover how we can very easily build b
.....
	</div>

```
#### grunt-contrib-watch

Following command will install grunt-contrib-watch and update the package.json:    

```
$ npm install grunt-contrib-watch --save-dev

```
Add following code into grunt's initConfig method, these code ensure that if file changes, grunt will run uglify and markdown task:     

```
watch :{
    scripts :{
      files : ['js/app.js','*.md','css/*.css'],
      tasks : ['uglify','markdown']
    }
  }

```
Add following line to Gruntfile for watch task:    

```
grunt.loadNpmTasks('grunt-contrib-watch');

```
Now run `grunt watch`, then modify some files, like `app.js` under `js` folder, then detect if the generated files are modified or not.    

Now run `grunt watch`, then modify some files, like `app.js` under `js` folder, then detect if the generated files are modified or not.     
#### livereload
Edit the watch's configuration, enable the livereload, this will enable the service in 35729 port. Or you could modify the service port by yourself.    
Add content into the templates/index.html:    

```
<script src="http://localhost:9090/livereload.js"></script>

``` 
Now every single modification will let you see the final result immediately.   

### Day 8 Harp.JS
Install the Harp.JS via:     

```
$ sudo npm install -g harp

```
Then initiate the blog via:    

```
$ harp init blog

```
This step won't be continue because the program will complain that `Template not found`.    
