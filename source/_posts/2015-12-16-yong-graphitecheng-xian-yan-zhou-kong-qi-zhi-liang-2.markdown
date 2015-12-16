---
layout: post
title: "用Graphite呈现广州空气质量(2)"
date: 2015-12-16 12:11:21 +0800
comments: true
categories: Visualization
---
### 更改后的脚本
以下脚本可以用于取回网页上的数据，并将其写入到Graphite远程服务器。    

```
#!/usr/bin/env python
#-*-coding:utf-8 -*-

##################################################################################
# For fetching back the Air Quality Data and write it into Graphite on local server
# Graphite Data Definition, this is the general definition among every city
# air.city.citypoint.so2
# air.city.citypoint.no2
# air.city.citypoint.pm10
# air.city.citypoint.co
# air.city.citypoint.o38h
# air.city.citypoint.pm25
# air.city.citypoint.aqi
# air.city.citypoint.firstp
# air.city.citypoint.overp
# When running this script in crontab, be sure to give it a display
# Example, execute this script every hour at xx:05
# 5 */1 * * * export DISPLAY=:0;/home/adminubuntu/GuangzhouPM25.py
##################################################################################

# BeautifulSoup
from bs4 import BeautifulSoup

# Selenium
from contextlib import closing
from selenium.webdriver import Firefox
from selenium.webdriver.support.ui import WebDriverWait

# For writing into Graphite
import platform
import socket
import time

# Regex
import re

# pinyin
import pinyin

# Parameters comes here 
CARBON_SERVER = '0.0.0.0'
CARBON_PORT = 2003
DELAY = 5  # secs
URL = 'http://210.72.1.216:8080/gzaqi_new/RealTimeDate.html'
CITY = 'guangzhou'

# All Points In Guangzhou City
positionsets = ["天河龙洞", "白云山", "麓湖", "公园前", "荔湾西村", "黄沙路边站", "杨箕
路边站", "荔湾芳村", "海珠宝岗", "海珠沙园", "海珠湖", "大夫山", "奥体中心", "萝岗西区
", "黄埔文冲", "黄埔大沙地", "亚运城", "体育西", "海珠赤沙"]

# regex for matching the digits.
pattern = re.compile(r'\d*')
floatpattern=re.compile(r'[\d|\.]*')

# Sending message to graphite server. 
def send_msg(message):
  print 'sending message:\n%s' % message
  sock = socket.socket()
  sock.connect((CARBON_SERVER, CARBON_PORT))
  sock.sendall(message)
  sock.close()

# Fetching data, runs each hour. In one-time access should fetch all of the data. 
def get_air_data(positionsets):
  # Dictionary hourdata is for holding data, DataStructure like: 
  # {'baiyunshan': [44, 5], 'haizhubaogang': [55, 6]}
  hourdata = {}
  # Calling selenium, need linux X
  browser = Firefox()
  browser.get(URL)
  # Click button one-by-one
  for position in positionsets:
    # After clicking, should re-get the page_source.
    browser.find_element_by_id(position).click()
    page_source = browser.page_source
    # Cooking Soup
    soup = BeautifulSoup(page_source, 'html.parser')
    # pm2.5 value would be something like xx 微克/立方米, so we need an regex for
    # matching, example: print int(pattern.match(input).group())
    PM25 = int(pattern.match(soup.find('td',{'id': 'pmtow'}).contents[0]).group())
    PM25_iaqi = int(pattern.match(soup.find('td',{'id':
'pmtow_iaqi'}).contents[0]).group())
    PM10 = int(pattern.match(soup.find('td',{'id': 'pmten'}).contents[0]).group())
    PM10_iaqi = int(pattern.match(soup.find('td',{'id':
'pmten_iaqi'}).contents[0]).group())
    SO2 = int(pattern.match(soup.find('td',{'id': 'sotwo'}).contents[0]).group())
    SO2_iaqi = int(pattern.match(soup.find('td',{'id':
'sotwo_iaqi'}).contents[0]).group())
    NO2 = int(pattern.match(soup.find('td',{'id': 'notwo'}).contents[0]).group())
    NO2_iaqi = int(pattern.match(soup.find('td',{'id':
'notwo_iaqi'}).contents[0]).group())
    # Special notice the CO would be float value
    CO = float(floatpattern.match(soup.find('td',{'id': 'co'}).contents[0]).group())
    CO_iaqi = int(pattern.match(soup.find('td',{'id': 'co_iaqi'}).contents[0]).group())
    O3 = int(pattern.match(soup.find('td',{'id': 'othree'}).contents[0]).group())
    O3_iaqi = int(pattern.match(soup.find('td',{'id':
'othree_iaqi'}).contents[0]).group())
    hourdata_key = pinyin.get(position)
    hourdata[hourdata_key] = []
    hourdata[hourdata_key].append(PM25)
    hourdata[hourdata_key].append(PM25_iaqi)
    hourdata[hourdata_key].append(PM10)
    hourdata[hourdata_key].append(PM10_iaqi)
    hourdata[hourdata_key].append(SO2)
    hourdata[hourdata_key].append(SO2_iaqi)
    hourdata[hourdata_key].append(NO2)
    hourdata[hourdata_key].append(NO2_iaqi)
    hourdata[hourdata_key].append(CO)
    hourdata[hourdata_key].append(CO_iaqi)
    hourdata[hourdata_key].append(O3)
    hourdata[hourdata_key].append(O3_iaqi)
  # After clicking all of the button, quit the firefox and return the dictionary
  browser.close()
  return hourdata

if __name__ == '__main__':
  airdata = get_air_data(positionsets)
  timestamp = int(time.time())
  for i in airdata.keys():
    # each key should contains the corresponding hourdata
    lines = [
      'air.guangzhou.%s.pm25 %s %d' % (i, airdata[i][0], timestamp),
      'air.guangzhou.%s.pm25_iaqi %s %d' % (i, airdata[i][1], timestamp),
      'air.guangzhou.%s.pm10 %s %d' % (i, airdata[i][2], timestamp),
      'air.guangzhou.%s.pm10_iaqi %s %d' % (i, airdata[i][3], timestamp),
      'air.guangzhou.%s.so2 %s %d' % (i, airdata[i][4], timestamp),
      'air.guangzhou.%s.so2_iaqi %s %d' % (i, airdata[i][5], timestamp),
      'air.guangzhou.%s.no2 %s %d' % (i, airdata[i][6], timestamp),
      'air.guangzhou.%s.no2_iaqi %s %d' % (i, airdata[i][7], timestamp),
      'air.guangzhou.%s.co %s %d' % (i, airdata[i][8], timestamp),
      'air.guangzhou.%s.co_iaqi %s %d' % (i, airdata[i][9], timestamp),
      'air.guangzhou.%s.o3 %s %d' % (i, airdata[i][10], timestamp),
      'air.guangzhou.%s.o3_iaqi %s %d' % (i, airdata[i][11], timestamp)
    ]
    message = '\n'.join(lines) + '\n'
    send_msg(message)
    # delay for graphite server will use a DELAY time for inserting data
    time.sleep(DELAY)
```

### 使用方法
将上面的文件保存为可执行文件，然后使用crontab添加一个定时任务，譬如以下的crontab条目会
在每个小时的xx:05分时自动运行该脚本文件，将取回的数据写入到Graphite远端。    

```
$ crontab -l
# hourly execute pm25 updating task, xx:05 will be the execute time
5 */1 * * * export DISPLAY=:0;/home/adminubuntu/GuangzhouPM25.py
```

写入graphite后的效果如下:    
![/images/2015_12_16_12_20_04_284x453.jpg](/images/2015_12_16_12_20_04_284x453.jpg)    

