---
layout: post
title: "Porting Weather APP Into Node.js(2)"
date: 2014-07-09 10:34
comments: true
categories: nodejs
---
Add packages dependencies:   

```
  "dependencies": {
    "express": "^4.5.1",
    "logfmt": "^1.1.2",
    "static-favicon": "~1.0.0",
    "morgan": "~1.0.0",
    "cookie-parser": "~1.0.1",
    "body-parser": "~1.0.0",
    "debug": "~0.7.4",
    "jade": "~1.3.0", 
    "mongodb": "*",
    "monk": "*"
  },

```
Then `npm install` to install the dependencies. 

Install the package and save the version in package.json:    

```
npm install forecast --save
npm install cron --save
npm install http --save
npm install cheerio --save

```

Merge the TestNanjing.js and web.js file, let the fetch to be a function, or to be module.    

