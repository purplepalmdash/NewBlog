---
layout: post
title: "判断python中值是否存在"
date: 2013-09-28 18:15
comments: true
categories: Python Linux
---
故事背景是这样的，写了一个自动获得美帝大使馆空气质量的python脚本，每隔一个小时取回数据存入数据库(数据库用Sqlite3), 并实时生成网页端的统计图形。然而当原始数据无法取得的时候，该程序会自动退出。因为脚本同时取得两个城市的PM值和温度/湿度，如果一个城市数据失败，另一个城市也将失败。    
运行时提示： name 'AQIdigits' is not defined, 这里的AQIdigits就是用来存储北京pm2.5数据的数组。   
解决方案，在插入数据前，检查数据是否存在，如果不存在，直接将其设置为0
{% codeblock %}
+  if (not('bj_temp' in vars() or 'bj_temp' in globals())):
+    bj_temp=0
+  if (not('bj_humi' in vars() or 'bj_humi' in globals())):
+    bj_humi=0
+  if (not(vars().has_key('AQIdigits'))):
+    AQIdigits = [u'0']
+  if (not(vars().has_key('Concendigits'))):
+    Concendigits = [u'0']
   cur_bj.execute('insert into foo values(?, ?, ? , ? ,?)', (bj_temp, bj_humi, AQIdigits[0], Concendigits[0], currenttime_linux))
   cur_bj.execute('select * from foo ORDER BY d_time ASC LIMIT ((Select count([d_time]) from foo)-24),24')
{% endcodeblock %}
这个修改做完之后，即便无法取回当前有效的数据值，脚本也会用0来代替需要插入的数据。众所周知，以北京的德行，pm2.5永远不可以为0的，所以当看到为0的时候，我们可以断言是源数据出错了。
