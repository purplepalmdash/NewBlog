---
layout: post
title: "Write Python Weather APP on Heroku(10)"
date: 2014-05-13 20:06
comments: true
categories: python
---
### Use Template In Flask
To use template in flask, we should put the static file under the `templates` folder under the root directory. Our index page should looks like following:     
![/images/frontpage.jpg](/images/frontpage.jpg)    

So our html file shall wrote like following:     

```html index.html
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>{{title}}</title>
<link rel="stylesheet" type="text/css" href="/static/assets/css/styles.css" />

<!--[if IE]><script src="assets/js/excanvas.min.js"></script><![endif]-->

</head>
<body>

<div id="page">
	<div id="header">
        <h1>{{title}}</h1>
        <h2>Nanjing Weather/PM Statistics</h2>

        <div id="periodDropDown">
        
        	<span class="left"></span>
            <span class="currentPeriod">Last 24 hours</span>
            <span class="arrow"></span>
            <span class="right"></span>
            
        	<ul>
            	<li data-action="24hours">Last 24 hours</li>
                <li data-action="7days">Last 7 Days</li>
                <li data-action="30days">Last 30 Days</li>
            </ul>
	</div>
	</div>

    <div class="temperature section">
    	<h3>Temperature</h3>
       	<div id="plot">
        	<span class="preloader"></span>
        </div>
    </div>

    <div class="humidity section">
	    <h3>Humidity</h3>
	    <div id="humi_plot">
		    <span class="preloader"></span>
	    </div>
    </div>
    
    <div class="pm2.5 section">
	    <h3>PM2.5</h3>
	    <div id="pm25_plot">
		    <span class="preloader"></span>
	    </div>
    </div>

    <div class="pm10 section">
	    <h3>PM10</h3>
	    <div id="pm10_plot">
		    <span class="preloader"></span>
	    </div>
    </div>

	

    
</div>

<p id="footer">
{{year}} &copy; {{title}}. Powered by <a href="kkkttt.github.io">Dash</a> UTC: {{utctime}}
</p>
<script src="/static/assets/js/jquery.min.js"></script>
<script src="/static/assets/js/script.js"></script>
<script src="/static/assets/js/jquery.flot.min.js"></script>

</body>
</html>

````
To use CSS file to make sure the vision effect, to use css in flask, put your files into the directory `static` under the root directory. Just like following :    

```sh run.sh
$ tree static 
static
└── assets
    ├── css
    │   └── styles.css
    ├── img
    │   ├── bg_tile.jpg
    │   ├── bg_vert.jpg
    │   ├── preloader.gif
    │   └── sprite.png
    └── js
        ├── jquery.flot.min.js
        ├── jquery.min.js
        └── script.js


```
### Rendering Html
In genhtml.py, we define the function which rendering the html template like following: 

```py genhtml.py
# @app.route('/index')
@app.route('/')
# Generate the index page, for debugging now
def index():
    # Use template for rendering the content
    Current_Year = datetime.now().strftime("%Y::%H:%M ")
    Current_UTC = datetime.utcnow().strftime("%H:%M")
    return render_template('index.html', title="NanJing Weather and PM2.5/10 Statistics", year=Current_Year, utctime=Current_UTC)

```
Now open your first page, you will see the rendered effect. But the flot div remains empty, next chapter we will introduce the javascript which used for draw the flot picture and AJAX which used for updating the content.    

