---
layout: post
title: "Porting Weather APP Into Node.js(3)"
date: 2014-07-12 16:19
comments: true
categories: nodejs
---
### Get the timstamp of the record
ObjectID could automatically store the insert timestamp, see following command:     

```
> db.usercollection.find().pretty()
........
........
> ObjectId("53be4e7eb5ca215e38c5f651").getTimestamp()
ISODate("2014-07-10T08:27:42Z")
> ObjectId("53be4e7cb5ca215e38c5f650").getTimestamp()
ISODate("2014-07-10T08:27:40Z")

```
### Time Format
Run following commands to get the timestamp since 1970:     

```
> day=new Date()
Sat Jul 12 2014 21:15:10 GMT+0800 (CST)
> day
Sat Jul 12 2014 21:15:10 GMT+0800 (CST)
> day.getTime()
1405170910049

```
The date which we fetched should be multiply 1000.    
And write a for loop for getting out the real date:   

```
      // helper function
      function getDate(d) {
          return new Date(d);
      }
      console.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
      // Refers to 1405170910049
      // WhatWeGet 1405170047
      // Should multiply 1000, Print out all of the timestamp
      for ( kk = 1; kk < 24; kk++)
      {
         console.log(getDate(date_data[kk]*1000));
      }

```

Print the type of the variable:    

```
console.log(typeof (#{weatherlist[3].Temperature}));

```


