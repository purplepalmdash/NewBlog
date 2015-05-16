---
layout: post
title: "Correcting My Weather Script"
date: 2013-11-02 16:42
comments: true
categories: Linux Python
---
Due to [http://haitao.smzdm.com/youhui/88923](http://haitao.smzdm.com/youhui/88923 "Nanjing") Nanjing Environmenmental Monitoring System changed their website, my python script can't fetch the correct data from this page, I have to find another data source, from [http://www.cnpm25.cn/city/nanjing.html](http://www.cnpm25.cn/city/nanjing.html "Nanjing 2"), but this source has about 1 hour's delay to the official site.    

Because the source changes, the previous script can't work any more, I made following changes, following is the changes in python code
{% codeblock change.py-change.py %}
	# table which contians the atmosphere information
	table = soup.find('table', {'id':'xiang1'})
		
	for subrows in rows:
	  if "玄武湖" in subrows.text:
	    XuanwuLake = subrows
	XuanwuLake_subitem = XuanwuLake.findAll('td')
	# PM 2.5
	pm_array[1] = XuanwuLake_subitem[3].text
	# PM 10
	pm_array[0] = XuanwuLake_subitem[4].text
	# Fetch only the digits from the output
	insert_pm25 = int(re.search('\d+', pm_array[1]).group())
	insert_pm10 = int(re.search('\d+', pm_array[0]).group())

	# Insert into the database
	cur.execute('insert into foo values(?, ?, ? , ? ,?)', (word1, word2, insert_pm10, insert_pm25, currenttime_linux))
{% endcodeblock %}

Also because the pollution is too serious, we have to change the following lines:

```
	-   yaxis: { min: 0, max: 200},
	+   yaxis: { min: 0, max: 300},
```


After reboot, we then see the result is updated . 

###Tips on delete the inserted sqlite3 records

```
	$ sqlite /srv/www1/weather1.db
	sqlite> select * from foo
	18|88|123|62.0|1383303610000
	19|83|258μg/m³|145μg/m³|1383395165000
	sqlite> .schema foo
	CREATE TABLE foo (d_temper integer, d_humi integer, d_pm10 integer, d_pm25 real, d_time timestamp);
	sqlite> delete from foo where d_time = 1383395165000;
```

