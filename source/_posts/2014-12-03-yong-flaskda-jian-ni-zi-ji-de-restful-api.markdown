---
layout: post
title: "用Flask搭建你自己的Restful API"
date: 2014-12-03 16:35
comments: true
categories: web
---
### 背景
最近在过一个《30天学习30种新技术》，过到第10天用Phonegap开发APP的时候，发现作者提供的API不可用，所以费心研究了一下Restful API, 顺利构建出了环境写完了那个APP，下面是一些摘要。    
我用的Tutorial来自这里：    
[http://blog.miguelgrinberg.com/post/designing-a-restful-api-with-python-and-flask](http://blog.miguelgrinberg.com/post/designing-a-restful-api-with-python-and-flask)     
开发环境是ArchLinux.      
### Hello Flask
原Tutorial中给出的是一个关于todo-list的实现，我们从最简单的"Hello Flask"开始：    
首先安装python虚拟环境和flask，注意因为Arch默认的python版本是3，所以这里我们使用了virtualenv2来创建python虚拟运行环境。    

```
$ mkdir todo-api
$ cd todo-api
$ virtualenv2 flask
$ source flask/bin/activate
(flask) $ pip install flask

```
在当前目录下建立`app.py`文件， 输入以下内容：    

``` py
#!flask/bin/python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Hello, Flask!"

if __name__ == '__main__':
    app.run(debug=True)

```
现在改变文件属性，运行之:    

```
$ chmod a+x app.py
$ ./app.py

```
打开浏览器访问`http://127.0.0.1:5000`,，我们可以看到Hello Flask已经出现在浏览器里了。    
### 实现最简单的Restful API
Flask本身支持很多插件，可以用于实现Restful API，由于我们这里只是做DEMO使用，需求比较简单，我们抛弃那些繁琐的插件，手动来写。    
这里我们也不会引入数据库等内容，我们将task任务列表直接保存在内存中，所以一旦断电这些数据就将消失。在实际的生产环境中，我们是需要引入不同的数据库来存储这些数据的。     
在上面生成的`app.py`中添加以下内容:    

``` py
#!flask/bin/python
from flask import Flask, jsonify

app = Flask(__name__)

tasks = [
    {
        'id': 1,
        'title': u'Buy groceries',
        'description': u'Milk, Cheese, Pizza, Fruit, Tylenol', 
        'done': False
    },
    {
        'id': 2,
        'title': u'Learn Python',
        'description': u'Need to find a good Python tutorial on the web', 
        'done': False
    }
]

@app.route('/todo/api/v1.0/tasks', methods=['GET'])

def get_tasks():
    return jsonify({'tasks': tasks})

if __name__ == '__main__':
    app.run(debug=True)

```
现在打开终端，用curl就可以访问到我们新添加的API了:    

``` sh
$ curl -i http://127.0.0.1:5000/todo/api/v1.0/tasks
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 316
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 08:59:55 GMT

{
  "tasks": [
    {
      "description": "Milk, Cheese, Pizza, Fruit, Tylenol", 
      "done": false, 
      "id": 1, 
      "title": "Buy groceries"
    }, 
    {
      "description": "Need to find a good Python tutorial on the web", 
      "done": false, 
      "id": 2, 
      "title": "Learn Python"
    }
  ]
}% 

```
第一个Restful的API就这样创建成功了。    
### 添加第二个RESTful API
我们接着来添加第二个RESTful API, 加入下列代码到已有的`app.py`中:     

``` py
from flask import abort

@app.route('/todo/api/v1.0/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = filter(lambda t: t['id'] == task_id, tasks)
    if len(task) == 0:
        abort(404)
    return jsonify({'task': task[0]})

```
现在用curl来测试，结果应该是这样的:     

```
(flask)[Trusty@~/code/30days/todo-api]$ curl -i http://127.0.0.1:5000/todo/api/v1.0/tasks/2
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 151
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:10:25 GMT

{
  "task": {
    "description": "Need to find a good Python tutorial on the web", 
    "done": false, 
    "id": 2, 
    "title": "Learn Python"
  }
}%                                                                                                                                                   (flask)[Trusty@~/code/30days/todo-api]$ curl -i http://127.0.0.1:5000/todo/api/v1.0/tasks/3
HTTP/1.0 404 NOT FOUND
Content-Type: text/html
Content-Length: 233
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:10:27 GMT

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>404 Not Found</title>
<h1>Not Found</h1>
<p>The requested URL was not found on the server.  If you entered the URL manually please check your spelling and try again.</p>

```
由于我们引用了abort方法，所以当我们给出的task id错误时，将弹出404错误。    
### 错误提示JSON化
通过引入`make_response`模块我们可以把404返回错误JSON化，添加以下代码到app.py中：    

```
from flask import make_response

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

```
现在访问一个不存在的task id将返回如下结果：     

```
(flask)[Trusty@~/code/30days/todo-api]$ curl -i http://127.0.0.1:5000/todo/api/v1.0/tasks/3
HTTP/1.0 404 NOT FOUND
Content-Type: application/json
Content-Length: 26
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:16:50 GMT

{
  "error": "Not found"
}%             

```
### 实现POST方法
添加以下代码以实现POST方法:     

```
from flask import request

@app.route('/todo/api/v1.0/tasks', methods=['POST'])
def create_task():
    if not request.json or not 'title' in request.json:
        abort(400)
    task = {
        'id': tasks[-1]['id'] + 1,
        'title': request.json['title'],
        'description': request.json.get('description', ""),
        'done': False
    }
    tasks.append(task)
    return jsonify({'task': task}), 201

```
用curl测试的结果如下：    

```
(flask)[Trusty@~/code/30days/todo-api]$ curl -i -H "Content-Type: application/json" -X POST -d '{"title":"Read a book"}' http://127.0.0.1:5000/todo/api/v1.0/tasks
HTTP/1.0 201 CREATED
Content-Type: application/json
Content-Length: 104
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:18:55 GMT

{
  "task": {
    "description": "", 
    "done": false, 
    "id": 3, 
    "title": "Read a book"
  }
}% 
 (flask)[Trusty@~/code/30days/todo-api]$ curl -i http://127.0.0.1:5000/todo/api/v1.0/tasks 
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 423
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:19:24 GMT

{
  "tasks": [
    {
      "description": "Milk, Cheese, Pizza, Fruit, Tylenol", 
      "done": false, 
      "id": 1, 
      "title": "Buy groceries"
    }, 
    {
      "description": "Need to find a good Python tutorial on the web", 
      "done": false, 
      "id": 2, 
      "title": "Learn Python"
    }, 
    {
      "description": "", 
      "done": false, 
      "id": 3, 
      "title": "Read a book"
    }
  ]
}%           

```
从上面的测试中我们可以看到一个新的任务被添加到了task列表中。     
### 最后两个RESTful API
最后的两个RESTful API代码如下:    

``` py
@app.route('/todo/api/v1.0/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    task = filter(lambda t: t['id'] == task_id, tasks)
    if len(task) == 0:
        abort(404)
    if not request.json:
        abort(400)
    if 'title' in request.json and type(request.json['title']) != unicode:
        abort(400)
    if 'description' in request.json and type(request.json['description']) is not unicode:
        abort(400)
    if 'done' in request.json and type(request.json['done']) is not bool:
        abort(400)
    task[0]['title'] = request.json.get('title', task[0]['title'])
    task[0]['description'] = request.json.get('description', task[0]['description'])
    task[0]['done'] = request.json.get('done', task[0]['done'])
    return jsonify({'task': task[0]})

@app.route('/todo/api/v1.0/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    task = filter(lambda t: t['id'] == task_id, tasks)
    if len(task) == 0:
        abort(404)
    tasks.remove(task[0])
    return jsonify({'result': True})

```
测试代码如下：     

```
$ curl -i -H "Content-Type: application/json" -X PUT -d '{"done":true}' http://127.0.0.1:5000/todo/api/v1.0/tasks/2

```
运行上面的命令可以将第2条记录里的done字段由false改成true.    

### 改进接口
加入以下代码后，我们调用tasks方法将不再返回id,而是返回URIs，这样取回来就能用了。      

``` py
from flask import url_for

def make_public_task(task):
    new_task = {}
    for field in task:
        if field == 'id':
            new_task['uri'] = url_for('get_task', task_id=task['id'], _external=True)
        else:
            new_task[field] = task[field]
    return new_task

```
同时我们重写以下方法:    

```
@app.route('/todo/api/v1.0/tasks', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': map(make_public_task, tasks)})

```
测试结果如下：    

```
$ curl -i http://127.0.0.1:5000/todo/api/v1.0/tasks
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 406
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:32:12 GMT

{
  "tasks": [
    {
      "description": "Milk, Cheese, Pizza, Fruit, Tylenol", 
      "done": false, 
      "title": "Buy groceries", 
      "uri": "http://127.0.0.1:5000/todo/api/v1.0/tasks/1"
    }, 
    {
      "description": "Need to find a good Python tutorial on the web", 
      "done": false, 
      "title": "Learn Python", 
      "uri": "http://127.0.0.1:5000/todo/api/v1.0/tasks/2"
    }
  ]
}% 

```
### 加密RESTful网络接口
好了，我们的RESTful接口搭建完毕了，但是由于接口对所有人都是开放的，为了考虑安全因素，我们会采用简单加密。     
首先安装flask-httpauth模块:     

```
$ pip install flask-httpauth

```
而后添加以下代码：    

```
from flask.ext.httpauth import HTTPBasicAuth
auth = HTTPBasicAuth()

@auth.get_password
def get_password(username):
    if username == 'miguel':
        return 'python'
    return None

@auth.error_handler
def unauthorized():
    return make_response(jsonify({'error': 'Unauthorized access'}), 401)

```
加密路由实现如下：    

```
@app.route('/todo/api/v1.0/tasks', methods=['GET'])
@auth.login_required
def get_tasks():
    return jsonify({'tasks': tasks})

```
测试结果如下, 未通过授权时:    

```
$ curl -i http://localhost:5000/todo/api/v1.0/tasks                 
HTTP/1.0 401 UNAUTHORIZED
Content-Type: application/json
Content-Length: 36
WWW-Authenticate: Basic realm="Authentication Required"
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:40:02 GMT

{
  "error": "Unauthorized access"
}%   

```
通过授权时:     

```
$ curl -u miguel:python -i http://localhost:5000/todo/api/v1.0/tasks
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 406
Server: Werkzeug/0.9.6 Python/2.7.8
Date: Wed, 03 Dec 2014 09:40:24 GMT

{
  "tasks": [
    {
      "description": "Milk, Cheese, Pizza, Fruit, Tylenol", 
      "done": false, 
      "title": "Buy groceries", 
      "uri": "http://localhost:5000/todo/api/v1.0/tasks/1"
    }, 
.....

```
我们可以把出错时返回的错误号从401改变为403,这样返回的就是forbidden错误。    
