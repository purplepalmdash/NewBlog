---
layout: post
title: "Write Python Weather APP on Heroku(7)"
date: 2014-05-11 13:44
comments: true
categories: python
---
We will continue to deploy our tasks on heroku. In this article we will finish the data retriving and database insertion.    
### Honcho
Install and Configuration of Honcho:

```
$ pip install honcho
# Regenerate requirement.txt and upload it onto heroku
$ mv Procfile ProcfileHoncho
# Edit the new Procfile: 
$ vim Procfile
web: honcho -f ProcfileHoncho start

```
In local, we can also use following command for swiftly verifying our code:

```
# Because our user belongs to root group, so set following variable firstly
$ export C_FORCE_ROOT=1
$ foreman start

```
Now you can visit http://localhost:5000 for viewing the result.     

### task.py
Following is the script for tasks.py: 

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Set default encoding: utf-8
import sys;
reload(sys);
# Setting the utf-8 format
sys.setdefaultencoding("utf8")


import logging
import string
from celery import Celery
from celery.task import periodic_task
from datetime import datetime,timedelta
from os import environ


# For retrieving temperature/humidity
import pywapi
import urllib2
from urllib2 import ProxyHandler
import re
from BeautifulSoup import BeautifulSoup

# For using database(Postgresql)
# from flash.ext.sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy import MetaData, Column, Table, ForeignKey
from sqlalchemy import Integer, String, DateTime


# redis configuration for celery
### Local, should be change to remote when deploying to heroku
REDIS_URL = environ.get('REDISTOGO_URL', 'redis://localhost')

celery = Celery('tasks', broker=REDIS_URL)

# Fetch 


# Define Periodic Tasks
# @periodic_task(run_every=timedelta(minutes=60))
# Funciton for fetching data and store it in Postgres
def fetch_and_store_data():
    # Fetching the weather information from Yahoo. 
    Yahoo_Result = pywapi.get_weather_from_yahoo('CHXX0099')
    Current_Temp = string.lower(Yahoo_Result['condition']['temp'])
    Current_Humi = string.lower(Yahoo_Result['atmosphere']['humidity'])
    Tomorrow_Forecast = Yahoo_Result['forecasts'][0]
    Twenty_Four_Hours = Yahoo_Result['forecasts'][1]
    Fourty_Eight_Hours = Yahoo_Result['forecasts'][2]
    Seventy_Two_Hours = Yahoo_Result['forecasts'][3]
    # !!! comment proxy related for deploying to heroku !!! #
    proxy = urllib2.ProxyHandler({'http': '192.11.236.225:8000'})
    opener = urllib2.build_opener(proxy)
    urllib2.install_opener(opener)
    page = urllib2.urlopen("http://www.pm25.in/nanjing")
    soup = BeautifulSoup(page)                      #
    # Find the detailed table from the soup.        #
    table = soup.find('table', {'id':'detail-data'})#
    # Fetch the XuanWuHu, if not, use MaiGaoQiao ins#tead. 
    rows = table.findAll('tr')                      #
    for subrows in rows:                            #
        if "玄武湖" in subrows.text:                #
            XuanwuLake = subrows                    #
        else:                                       #
            if "迈皋桥" in subrows.text:            #
                XuanwuLake = subrows                #
    XuanwuLake_subitem = XuanwuLake.findAll('td')   #
    # Here we will get an array, fetch out the text #for the content from this array.
    # Fetched origin data, different from cnpm25.cn #
    pm_25_orig = XuanwuLake_subitem[4].text         #
    pm_10_orig = XuanwuLake_subitem[5].text
    # Open the Database
    engine = create_engine('postgresql+psycopg2://Trusty:@localhost:5432/mylocaldb',echo=True)
    metadata=MetaData(bind=engine)
    
    # Definition of the weather table
    weather_table=Table('weather',metadata,
    	Column('Insert_Time', DateTime(timezone=True),primary_key=True),
    	Column('Temperature', Integer),
    	Column('Humidity', Integer),
    	Column('PmTen', Integer),
    	Column('PmTwoFive', Integer),
    )

    # Create the table in mylocaldb
    metadata.create_all(checkfirst=True)

    # Record Insertion
    # First generate an insertion sentense:
    ins = weather_table.insert()
    # Really insert into the Database
    # ins = weather_table.insert().values(Insert_Time=datetime.datetime.utcnow(), Temperature=25, Humidity=75, PmTen=100, PmTwoFive=55)   # Example
    ins = weather_table.insert().values(Insert_Time=datetime.utcnow(), Temperature=Current_Temp, Humidity=Current_Humi, PmTen=int(pm_10_orig), PmTwoFive=int(pm_25_orig))
    # Connect to engine and execute.
    conn = engine.connect()
    result = conn.execute(ins)

    #return Current_Temp
    return pm_25_orig



@periodic_task(run_every=timedelta(seconds=10))
def print_fib():
    #logging.info(fib(30))
    logging.info("This could be viewed in logging!")

```
Notice, this version only works in local.  
For updating the real database on heroku, we have to do some modification on redis server and remove the proxy server, these are the works we need to done in next chapter.    
