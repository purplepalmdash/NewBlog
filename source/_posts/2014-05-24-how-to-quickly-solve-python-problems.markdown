---
layout: post
title: "How to quickly solve python problems"
date: 2014-05-24 10:58
comments: true
categories: python
---
### 问题
在txt里面打印1-10里面随机的9个数。    
### 思路
#### 如何生成随机数？     
Google "generate  random python" , 结果如下：     
![/images/python1.jpg](/images/python1.jpg)    

挨个看，马上你会发现下面这个网页有答案：    
[http://stackoverflow.com/questions/5555712/generate-a-random-number-in-python](http://stackoverflow.com/questions/5555712/generate-a-random-number-in-python)    

启动终端试验之：    

```
$ python
Python 2.7.6 (default, Feb 26 2014, 12:07:17) 
[GCC 4.8.2 20140206 (prerelease)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from random import randint
>>> randint(2,9)
3
>>> randint(1,10)
9
>>> randint(1,10)
4

```

#### 如何循环打印   
照样Google, 搜索关键字" python loop times",结果如下：    
![/images/python2.jpg](/images/python2.jpg)    
随便点点看， 发现python自己的文档里就已经有很详细的关于loop的例子了:   
[https://wiki.python.org/moin/ForLoop](https://wiki.python.org/moin/ForLoop)    

试验之:    

```
>>> for x in range(0,3):
...     print "hello"
... 
hello
hello
hello

```

### 综合，得出答案    
用for的实现:    

```
>>> for x in range(0,9):
...     print random.randrange(1,10)
... 
2
5
3
7
9
4
7
3
1

```
发散到用while的实现(原代码见上面的wiki网页)      

```
>>> x = 1
>>> while x < 10:
...     print random.randrange(1,10)
...     x += 1
... 
4
4
4
5
1
9
1
8
2

```
当然你还可以反着弄while:    

```
>>> x = 10
>>> while x > 0:
等等等等，不提示了

````


