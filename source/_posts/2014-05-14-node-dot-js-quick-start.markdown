---
layout: post
title: "Node.js Quick Start"
date: 2014-05-14 19:53
comments: true
categories: nodejs
---
### Installation
Via following command

```
$ yaourt -S nodejs

```
### Quick Start

```
$ node
> console.log("Hello!")
Hello!
undefined

```
Hit twice "Ctrl+c" you will get out of the terminal.     
A simple example is like:   

```js server.js
var http = require("http");

http.createServer(function(request, response) {
	  response.writeHead(200, {"Content-Type": "text/plain"});
	    response.write("Hello World");
	      response.end();
}).listen(8888);
$ node server.js

$ curl http://localhost:8888
Hello World%

```

