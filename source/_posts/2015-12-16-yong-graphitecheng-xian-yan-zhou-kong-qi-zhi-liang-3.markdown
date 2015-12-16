---
layout: post
title: "用Graphite呈现广州空气质量(3)"
date: 2015-12-16 14:18:25 +0800
comments: true
categories: visualization
---
### 当前节点无数据
我们的脚本加入crontab运行后，最开始是可以得到数据的，后面两小时它挂了，查原因，有以下的
报错信息:    

```
# /home/adminubuntu/GuangzhouPM25.py 
Traceback (most recent call last):
  File "/home/adminubuntu/GuangzhouPM25.py", line 112, in <module>
    airdata = get_air_data(positionsets)
  File "/home/adminubuntu/GuangzhouPM25.py", line 80, in get_air_data
    PM25 = int(pattern.match(soup.find('td',{'id': 'pmtow'}).contents[0]).group())
ValueError: invalid literal for int() with base 10: ''
```
此时selenium控制的浏览器停在以下图例:    

![/images/2015_12_16_14_21_03_497x301.jpg](/images/2015_12_16_14_21_03_497x301.jpg)    

可以看到，如果当前节点的数据为`--`， 则我们的python脚本运行会出现问题。因而我们在代码中
要加入少量修改。  
### 错误处理
以下的代码更改添加了错误处理，如果该监测点的数值为空，则不提交任何数据:    

```
@@ -66,9 +66,9 @@ def get_air_data(positionsets):
   hourdata = {}
   # Calling selenium, need linux X
   browser = Firefox()
-  # Added 10 seconds for waiting page for loading.
-  time.delay(10)
   browser.get(URL)
+  # Added 10 seconds for waiting page for loading.
+  time.sleep(10)
   # Click button one-by-one
   for position in positionsets:
     # After clicking, should re-get the page_source.
@@ -78,33 +78,37 @@ def get_air_data(positionsets):
     soup = BeautifulSoup(page_source, 'html.parser')
     # pm2.5 value would be something like xx 微克/立方米, so we need an regex for
     # matching, example: print int(pattern.match(input).group())
-    PM25 = int(pattern.match(soup.find('td',{'id': 'pmtow'}).contents[0]).group())
-    PM25_iaqi = int(pattern.match(soup.find('td',{'id': 'pmtow_iaqi'}).contents[0]).group())
-    PM10 = int(pattern.match(soup.find('td',{'id': 'pmten'}).contents[0]).group())
-    PM10_iaqi = int(pattern.match(soup.find('td',{'id': 'pmten_iaqi'}).contents[0]).group())
-    SO2 = int(pattern.match(soup.find('td',{'id': 'sotwo'}).contents[0]).group())
-    SO2_iaqi = int(pattern.match(soup.find('td',{'id': 'sotwo_iaqi'}).contents[0]).group())
-    NO2 = int(pattern.match(soup.find('td',{'id': 'notwo'}).contents[0]).group())
-    NO2_iaqi = int(pattern.match(soup.find('td',{'id': 'notwo_iaqi'}).contents[0]).group())
-    # Special notice the CO would be float value
-    CO = float(floatpattern.match(soup.find('td',{'id': 'co'}).contents[0]).group())
-    CO_iaqi = int(pattern.match(soup.find('td',{'id': 'co_iaqi'}).contents[0]).group())
-    O3 = int(pattern.match(soup.find('td',{'id': 'othree'}).contents[0]).group())
-    O3_iaqi = int(pattern.match(soup.find('td',{'id': 'othree_iaqi'}).contents[0]).group())
-    hourdata_key = pinyin.get(position)
-    hourdata[hourdata_key] = []
-    hourdata[hourdata_key].append(PM25)
-    hourdata[hourdata_key].append(PM25_iaqi)
-    hourdata[hourdata_key].append(PM10)
-    hourdata[hourdata_key].append(PM10_iaqi)
-    hourdata[hourdata_key].append(SO2)
-    hourdata[hourdata_key].append(SO2_iaqi)
-    hourdata[hourdata_key].append(NO2)
-    hourdata[hourdata_key].append(NO2_iaqi)
-    hourdata[hourdata_key].append(CO)
-    hourdata[hourdata_key].append(CO_iaqi)
-    hourdata[hourdata_key].append(O3)
-    hourdata[hourdata_key].append(O3_iaqi)
+    try:
+      PM25 = int(pattern.match(soup.find('td',{'id': 'pmtow'}).contents[0]).group())
+      PM25_iaqi = int(pattern.match(soup.find('td',{'id': 'pmtow_iaqi'}).contents[0]).group())
+      PM10 = int(pattern.match(soup.find('td',{'id': 'pmten'}).contents[0]).group())
+      PM10_iaqi = int(pattern.match(soup.find('td',{'id': 'pmten_iaqi'}).contents[0]).group())
+      SO2 = int(pattern.match(soup.find('td',{'id': 'sotwo'}).contents[0]).group())
+      SO2_iaqi = int(pattern.match(soup.find('td',{'id': 'sotwo_iaqi'}).contents[0]).group())
+      NO2 = int(pattern.match(soup.find('td',{'id': 'notwo'}).contents[0]).group())
+      NO2_iaqi = int(pattern.match(soup.find('td',{'id': 'notwo_iaqi'}).contents[0]).group())
+      # Special notice the CO would be float value
+      CO = float(floatpattern.match(soup.find('td',{'id': 'co'}).contents[0]).group())
+      CO_iaqi = int(pattern.match(soup.find('td',{'id': 'co_iaqi'}).contents[0]).group())
+      O3 = int(pattern.match(soup.find('td',{'id': 'othree'}).contents[0]).group())
+      O3_iaqi = int(pattern.match(soup.find('td',{'id': 'othree_iaqi'}).contents[0]).group())
+      hourdata_key = pinyin.get(position)
+      hourdata[hourdata_key] = []
+      hourdata[hourdata_key].append(PM25)
+      hourdata[hourdata_key].append(PM25_iaqi)
+      hourdata[hourdata_key].append(PM10)
+      hourdata[hourdata_key].append(PM10_iaqi)
+      hourdata[hourdata_key].append(SO2)
+      hourdata[hourdata_key].append(SO2_iaqi)
+      hourdata[hourdata_key].append(NO2)
+      hourdata[hourdata_key].append(NO2_iaqi)
+      hourdata[hourdata_key].append(CO)
+      hourdata[hourdata_key].append(CO_iaqi)
+      hourdata[hourdata_key].append(O3)
+      hourdata[hourdata_key].append(O3_iaqi)
+    except ValueError, Argument:
+      # won't add the data, simply ignore this position
+      print "The argument does not contain numbers\n", Argument
   # After clicking all of the button, quit the firefox and return the dictionary
   browser.close()
   return hourdata
``` 
到现在为止，数据可以顺利的写入到Graphite中。    

### Graphite Dashboard
组建Graphite Dashboard可以通过图形界面来进行，举例如下:    

![/images/2015_12_16_15_22_04_579x386.jpg](/images/2015_12_16_15_22_04_579x386.jpg)    

具体的添加过程就不说了，值得注意的是，设置几个属性，时间范围为过去24小时，
双击某图片后，`Render Options`里的`Line Mode`选择`Connected Line`， 
这样可以构建出连接线，比较适合我们所需要展示的数据类型。Y-Axis，即Y轴的起点(Minimal)设置为0.   

点击DashBoard-> Edit Dashboard, 可以看到以下定义:    

![/images/2015_12_16_15_25_54_789x499.jpg](/images/2015_12_16_15_25_54_789x499.jpg)    

这个定义文件可以修改，我们将使用这个定义文件来批量制作其他十多个监测点的Dashboard.    

### 创建更多的Dashboard
参考:     
[http://graphite.readthedocs.org/en/latest/dashboard.html#editing-importing-and-exporting-via-json](http://graphite.readthedocs.org/en/latest/dashboard.html#editing-importing-and-exporting-via-json)    

将上述的dashboard定义文件存储在某个文本文件中，
用下列命令批量生成新的dashboard定义文件:    

```
$ cat dashboard.txt | sed 's/haizhuhu/aotizhongxin/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/aotizhongxin/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/baiyunshan/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/dafushan/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/gongyuanqian/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/haizhubaogang/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/haizhuchisha/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/haizhuhu/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/haizhushayuan/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/huangpudashadi/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/huangpuwenchong/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/huangshalubianzhan/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/liwanfangcun/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/liwanxicun/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/luhu/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/luogangxiqu/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/tianhelongdong/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/tiyuxi/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/yayuncheng/g'|myclip
$ cat dashboard.txt | sed 's/haizhuhu/yangjilubianzhan/g'|myclip
``` 

`myclip`是一个自定义的命令，可以将管道输出直接到系统剪贴板，
而后将内容新添加到dashboard定义文件中，点击update后，另存为新的dashboard即可.    
