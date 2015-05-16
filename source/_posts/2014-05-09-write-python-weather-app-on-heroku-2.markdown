---
layout: post
title: "Write Python Weather APP on Heroku(2)"
date: 2014-05-09 15:19
comments: true
categories: python
---
### Get Current Weather Data
Now we begin to change our APP to a real funny staff. First we change the hello.py and begin to write our own "genhtml.py"   

```
$ mv hello.py genhtml.py
$ cat Procfile
web: gunicorn genhtml:app

```
We know there is an python library which we could install from pip named "pywapi", simply install it via:    

```
(venv2) $ pip install pywapi

```
If your pip's version is 1.5.1, then notice you have to use following command for installing the pywapi:   

```
(venv2) $ pip install pywapi --allow-external pywapi --allow-unverified pywapi
Downloading/unpacking pywapi
  pywapi is potentially insecure and unverifiable.
  Downloading pywapi-0.3.8.tar.gz
  Running setup.py (path:/home/Trusty/code/herokuWeatherApp/venv/build/pywapi/setup.py) egg_info for package pywapi
    
Installing collected packages: pywapi
  Running setup.py install for pywapi
    
Successfully installed pywapi
Cleaning up...

```
Now change the genhtml.py to following content:    

```py genhtml.py
import os
from flask import Flask

import pywapi
import string

app = Flask(__name__)

@app.route('/')

# Generate the Nanjing Weather Data
def genhtml():
    Yahoo_Result = pywapi.get_weather_from_yahoo('CHXX0099')
    Current_Temp = string.lower(Yahoo_Result['condition']['temp'])
    Current_Humi = string.lower(Yahoo_Result['atmosphere']['humidity'])
    Tomorrow_Forecast = Yahoo_Result['forecasts'][0]
    Twenty_Four_Hours = Yahoo_Result['forecasts'][1]
    Fourty_Eight_Hours = Yahoo_Result['forecasts'][2]
    Seventy_Two_Hours = Yahoo_Result['forecasts'][3]
    return Current_Temp

```
After modification, we use "foreman start" for previewing the result, we can see the webpage returns the current temperature of Nanjing, its value is 25, as in following picture:    
![/images/current_temp.jpg](/images/current_temp.jpg)   

This shows the pywapi could be work together with other components, we will continue for next step.    
###Deployment On Heroku
You need to change the requirement.txt file like following:   

```
$ cat requirements.txt
--allow-all-external
--allow-unverified pywapi
Flask==0.10.1
Jinja2==2.7.2
MarkupSafe==0.23
Werkzeug==0.9.4
gunicorn==18.0
itsdangerous==0.24
pywapi==0.3.8
wsgiref==0.1.2

```
Then run "git push heroku master", open your browser and visit [http://python-weather-app.herokuapp.com/](http://python-weather-app.herokuapp.com/), the output the same as in local.   

By now, we have created a very simple app on getting the current temperature of nanjing, next chapter we will use database for timely record the data.    
