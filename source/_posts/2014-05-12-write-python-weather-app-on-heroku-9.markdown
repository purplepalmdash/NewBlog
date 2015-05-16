---
layout: post
title: "Write Python Weather APP on Heroku(9)"
date: 2014-05-12 10:48
comments: true
categories: python
---
### Understanding the flask and Jinja
#### Flask Example
hello1.py is listed as following:

```
from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return 'Index Page'

@app.route('/hello')
def hello():
    return "Hello World!"

@app.route('/hello1')
def hello1():
    return "Hello World 1!"

if __name__ == "__main__":
    app.run()

```
Run this via:    

```
$ python hello1.py

```
Then use your browser for visiting http://localhost:5000, http://localhost:5000/hello, http://localhost:5000/hello1. You will view different output result.    
#### Jinja Example
The sample.py is listed as following:    

```
# Load the jinja library's namespace into the current module.
import jinja2

# In this case, we will load templates off the filesystem.
# This means we must construct a FileSystemLoader object.
# 
# The search path can be used to make finding templates by
#   relative paths much easier.  In this case, we are using
#   absolute paths and thus set it to the filesystem root.
templateLoader = jinja2.FileSystemLoader( searchpath="/" )

# An environment provides the data necessary to read and
#   parse our templates.  We pass in the loader object here.
templateEnv = jinja2.Environment( loader=templateLoader )

# This constant string specifies the template file we will use.
TEMPLATE_FILE = "//home/Trusty/code/python/heroku/Jinja2/example1.jinja"

# Read the template file using the environment object.
# This also constructs our Template object.
template = templateEnv.get_template( TEMPLATE_FILE )

# Specify any input variables to the template as a dictionary.
templateVars = { "title" : "Test Example",
                 "description" : "A simple inquiry of function." }

# Finally, process the template to produce our final text.
outputText = template.render( templateVars )
print outputText

```
Create the example1.jinja at the corresponding directory, contains following content:    

```
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />

  <title>{{ title }}</title>
  <meta name="description" content="{{ description }}" />
</head>

<body>

<div id="content">
  <p>Why, hello there!</p>
</div>

</body>
</html>

```
Then the result will viewed as following:    

```
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />

  <title>Test Example</title>
  <meta name="description" content="A simple inquiry of function." />
</head>

<body>

<div id="content">
  <p>Why, hello there!</p>
</div>

</body>
</html>

```
### Rendering Template Returning
First create the template file under the directory 'templates', this is the default position for flask for searching the template files:    

```
$ mkdir templates
$ cat layout.html
<style type="text/css">
.metanav
{
    background-color: yellow;
}
</style>
<div class="page">
  <h1>Flaskr</h1>
  <div class="metanav">
  {{ a_random_string }}
  {{ a_random_list[3] }}
  </div>
</div>

```
Then in the genhtml.py, we add the following lines for let the template system to rendering our pages:   

```
from flask import render_template
@app.route('/index')
# Generate the index page, for debugging now
def index():
    # Use template for rendering the content
    rand_list= [0, 1, 2, 3, 4, 5]
    return render_template('layout.html', a_random_string="Heey, what's up!", a_random_list=rand_list)

```
Now browser you http://localhost:5000/index, you can see the template rendered result.    
