---
layout: post
title: "用Python生成当前城市的空气/气候数据"
date: 2013-09-10 21:00
comments: true
categories: Linux Python
---
最近空气污染很严重，临时写了这个脚本，用来即时生成当前城市的空气质量和温度、湿度等指数。

1\. 安装python虚拟运行环境，因为ArchLinux上的python版本是3,需要安装2.x的python，如果你能确认自己机器上的python版本是2,这步可以忽略：  
{% codeblock %}
$ mkvirtualenv -p /usr/bin/python2.7 venv2
$ workon venv2
{% endcodeblock %}

2\. 安装beautiful soup和pywapi， pip是python安装环境，BeautifulSoup用来解析html/xml， pywapi是一个用于取得天气数据的库:  
{% codeblock %}
$ pip install BeautifulSoup 
$ pip install pywapi
{% endcodeblock %}

3\. 输入下面的代码, 将此文件存放为/usr/bin/genhtm.py, 并赋予执行权限:
{% codeblock genhtml.py - genhtml.py%}
#!/usr/bin/python
# -*- coding: utf-8 -*-
# Using BeautifulSoup for analyse the html file
from BeautifulSoup import BeautifulSoup
import urllib2
# Using pywapi for getting the weather data
import pywapi
import string
# Using django for generating the data
from django.template import Template, Context
from django.conf import settings
settings.configure() # We have to do this to use django templates standalone - see
# http://stackoverflow.com/questions/98135/how-do-i-use-django-templates-without-the-rest-of-django
# Time
from time import gmtime, strftime, localtime

def printweather(city):
	print "\nYahoo says: It is " + string.lower(yahoo_result['condition']['text']) + " and " + yahoo_result['condition']['temp'] + " C now in " + city + "!"#ShangHai, MODU!!!!"
	print "Yahoo says the humidity is " + string.lower(yahoo_result['atmosphere']['humidity'])
	print "Yahoo says the sunrise is " + string.lower(yahoo_result['astronomy']['sunrise'])
	print "Yahoo says the sunset is " + string.lower(yahoo_result['astronomy']['sunset'])

pm_array=[2,10]
i = 0

########### Generate the PM2.5 and PM10 Information of NanJing #######
page = urllib2.urlopen("http://222.190.111.117:8023/")
soup = BeautifulSoup(page)
table = soup.find('table', {'class':'table01'})
rows = table.findAll('tr')
for tr in rows:
	cols = tr.findAll('td')
	if len(cols) >=4 and "PM" in cols[0].text and "1" in cols[1].text:
		#print cols[0].contents[0]+' '+cols[0].sub.string+'\t'+cols[2].string
		#pm_array[i] = cols[0].contents[0]+' '+cols[0].sub.string+'\t'+cols[2].string
		pm_array[i] = cols[2].string
		i = i+1

########### Generate the Weather Information from Yahoo Weather#######
#Nanjing
yahoo_result = pywapi.get_weather_from_yahoo('CHXX0099')
word1 = string.lower(yahoo_result['condition']['temp'])
word2 = string.lower(yahoo_result['atmosphere']['humidity'])

# Our template. Could just as easily be stored in a separate file
template = """
<html>
<head>
<title>{{ title }}</title>
</head>
<body>
<h1>NanJing,NanJing!!!</h1>
<h2>Temperature</h2>
<p>{{ temper }} C</p>
<h2>Humidity</h2>
<p>{{ humi }} %</p>
<h2>PM10</h2>
<p>{{ pm10 }}</p>
<h2>PM2.5</h2>
<p>{{ pm25 }}</p>
<h2>I Feel as if I will be choked!!!</h2>
<h2>Generated at: </h2>
<p>{{ generated_time }}</p>
</body>
</html>
"""

t = Template(template)
c = Context({"title": "NanJing Weather&PM10/2.5 Data",
             #"mystring":"string from code",
	     "temper" : word1,
	     "humi" : word2,
	     "pm10" : pm_array[0],
	     "pm25" : pm_array[1],
	     "generated_time" : strftime("%Y-%m-%d %H:%M:%S", localtime()),
})
f = open('/srv/www1/index.html', 'w')
f.write(t.render(c))
f.close()
{% endcodeblock %}

注意：你需要更改具体的数据源为你自己所在城市的源，上面的文件仅适合于南京。


4\. 配置nginx， 使其配置指向我们刚才生成的文件夹/srv/www1/， 由于默认的文件名为index.html，nginx可以正确处理html请求,一个配置例子如下, 具体的配置需要根据自己机器的实际情况来配置：
{% codeblock %}
/etc/nginx/sites-available/default
server {
	listen   8009; ## listen for ipv4; this line is default and implied
	#listen   [::]:80 default_server ipv6only=on; ## listen for ipv6

	root /srv/www1;
	index index.html index.htm;

	# Make site accessible from http://localhost/
	server_name localhost;
..............
{% endcodeblock %}

5.\将该python脚本加入到crontab，并设置为每一个小时运行一次：
{% codeblock %}
$ crontab -e
#在文件末尾加入：
*/60 * * * * /usr/bin/genhtml.py
{% endcodeblock %}


现在你已经拥有了一个可以动态更新相关数据的网页, [http://127.0.0.1:8009](http://127.0.0.1:8009)就可以访问到具体结果，当然如果你配置了本机上的DDNS的话，你可以通过你的DDNS地址来访问本机网页：[http://Your_DDNS_Addr:8009/](http://Your_DDNS_Addr:8009/)
