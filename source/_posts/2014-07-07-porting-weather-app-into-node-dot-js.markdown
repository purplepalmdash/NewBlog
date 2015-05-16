---
layout: post
title: "Porting Weather APP Into Node.js"
date: 2014-07-07 18:36
comments: true
categories: nodejs
---
### Website Design
Use express for generating the whole website.   

```
$ pwd 
/home/Trusty/code/nodejs/weather
[Trusty@~/code/nodejs/weather]$ express weather

```
The express framework will be generated.     

Add following dependencies into the weather/package.json:    

```
    "jade": "~1.3.0", 
    "mongodb": "*",
    "monk": "*"

```

Install packages:    

```
$ cd weather
$ npm install

```

`mkdir data`, this command will create a directory named `data` which is used for holding our mongodb.    
Now visit [http://localhost:3000/](http://localhost:3000/) you will see the demo html website.    

This website should have the inteface for operating the database(MongoDB), so I will add some sub-pages for handling the request for insert and query the database.    
#### Insert Records Into MongoDB
Design database in MongoDB:    

```
$ mongo
$ show dbs
admin       (empty)
local       0.078GB
my-website  0.078GB
mydb        0.078GB
nodetest1   0.078GB
test        (empty)
$ use weathertest

```
The DataSet should be designed as following:    

```
{
    "_id" : 1234,
    "AQI" : "70",
    "Level" : "良", 
    "FirstPollution" : "臭氧1小时", 
    "PM2_5" : "51", 
    "PM10" : "70", 
    "CO" : "0.148", 
    "NO2" : "31", 
    "O3_1hour" : "168", 
    "O3_8hour" : "68", 
    "S02" : "13" 
}

```
So the insert sentense should be like following:    

```
db.usercollection.insert({ "AQI" : "70", "Level" : "良", "FirstPollution" : "臭氧1小时", "PM2_5" : "51", "PM10" : "70", "CO" : "0.148", "NO2" : "31", "O3_1hour" : "168", "O3_8hour" : "68", "SO2" :"13"})

```
Verify the insert result via:    

```
> db.usercollection.find().pretty()
{
	"_id" : ObjectId("53ba7e137346b7523d951084"),
	"AQI" : "70",
	"Level" : "良",
	"FirstPollution" : "臭氧1小时",
	"PM2_5" : "51",
	"PM10" : "70",
	"CO" : "0.148",
	"NO2" : "31",
	"O3_1hour" : "168",
	"O3_8hour" : "68",
	"SO2" : "13"
}

```
Should add more informations into the database, for example the temperature/humidity, which could also be fetched via npm package.    
First delete the inserted item via following command:    

```
> db.usercollection.remove({"_id" : ObjectId("53ba7e137346b7523d951084")});
WriteResult({ "nRemoved" : 1 })
> db.usercollection.find().pretty()

```

Then insert a new organized records and verify the insertion :    

```
db.usercollection.insert({ "Temperature" : "21.9", "DewPoint" : "19.93", "Humidity" : "0.89", "Pressure" : "1004.85", "Ozeone" : "289.03",  "AQI" : "70", "Level" : "良", "FirstPollution" : "臭氧1小时", "PM2_5" : "51", "PM10" : "70", "CO" : "0.148", "NO2" : "31", "O3_1hour" : "168", "O3_8hour" : "68", "SO2" :"13", "CurrentTime": "ISODate()"})
> db.usercollection.find().pretty()
{
	"_id" : ObjectId("53ba82f97346b7523d951085"),
	"Temperature" : "21.9",
	"DewPoint" : "19.93",
	"Humidity" : "0.89",
	"Pressure" : "1004.85",
	"Ozeone" : "289.03",
	"AQI" : "70",
	"Level" : "良",
	"FirstPollution" : "臭氧1小时",
	"PM2_5" : "51",
	"PM10" : "70",
	"CO" : "0.148",
	"NO2" : "31",
	"O3_1hour" : "168",
	"O3_8hour" : "68",
	"SO2" : "13"
}

```
We will insert many many records into the database, how to distinguish them? By Timestamp!!!    

In MongoDB we have the built-in Function Date():    

```
> Date()
Mon Jul 07 2014 19:29:36 GMT+0800 (CST)

```

Each inserted Dataset's timestamp could be fetched out via following command:     

```
> ObjectId("53ba876d7346b7523d951088").getTimestamp()
ISODate("2014-07-07T11:41:33Z")

```

Next step is using node.js api for processing the dataset.    

#### Display The Inserted Records
We want to display the result like following:     

```
<ul>
    <li>Temperature: 21.9, DewPoint: 19.93, Humidity: 0.89, Pressure: 1004.85, Ozeone: 289.03, AQI: 70, Level: 良, FirstPollution: 臭氧1小时, PM2.5: 51, PM10: 70, CO: 0.148, NO2: 31, O3一小时： 168, O3八小时： 68, So2: 13。 </li>
    <li>Temperature: 21.9, DewPoint: 19.93, Humidity: 0.89, Pressure: 1004.85, Ozeone: 289.03, AQI: 70, Level: 良, FirstPollution: 臭氧1小时, PM2.5: 51, PM10: 70, CO: 0.148, NO2: 31, O3一小时： 168, O3八小时： 68, So2: 13。 </li>
    <li>Temperature: 21.9, DewPoint: 19.93, Humidity: 0.89, Pressure: 1004.85, Ozeone: 289.03, AQI: 70, Level: 良, FirstPollution: 臭氧1小时, PM2.5: 51, PM10: 70, CO: 0.148, NO2: 31, O3一小时： 168, O3八小时： 68, So2: 13。 </li>
</ul>

```
Change the router/index.js, add following lines:    

```
/* GET weatherlist page. */
router.get('/weatherlist', function(req, res) {
    var db = req.db;
    var collection = db.get('usercollection');
    collection.find({},{},function(e,docs){
        res.render('weatherlist', {
            "weatherlist" : docs
        });
    });
});

```
Add the new file named `weatherlist.jade` under views/ folder:    

```
block content
    h1.
        Weather List
    ul
        each weather, i in weatherlist
            li
                首要污染物: #{weather.FirstPollution}, <br />级别: #{weather.Level},<br />AQI: #{weather.AQI},<br />PM2.5: #{weather.PM2_5},<br />PM10: #{weather.PM10}, <br />一氧化碳: #{weather.CO}, <br />二氧化氮: #{weather.NO2}, <br />臭氧一小时浓度: #{weather.O3_1hour}, <br />臭氧八小时浓度: #{weather.O3_8hour}, <br />二氧化硫: #{weather.SO2}, <br />温度: #{weather.Temperature}, <br />露点: #{weather.DewPoint}, <br />湿度: #{weather.Humidity}, <br />气压: #{weather.Pressure}, <br />Ozeone: #{weather.Ozeone}

```
Now visit [http://localhost:3000/weatherlist](http://localhost:3000/weatherlist) we could see the record has been listed on the page.    

#### Insert Records In Nodejs
We should use a crontab task for inserting the record once we fetched the data.    
The fetching process could be seperated from the web frame, or we could put the script into the directory, and let cron run it, it's OK.   

Following is a sample code for inserting record into mongoDB:    

```
/* 
* This example uses the node MongoDB module to connect to the local
* mongodb database on this virtual machine
*
* More here: http://mongodb.github.io/node-mongodb-native/markdown-docs/insert.html
*/

//require node modules (see package.json)
var MongoClient = require('mongodb').MongoClient
    , format = require('util').format;

//connect away
MongoClient.connect('mongodb://127.0.0.1:27017/test', function(err, db) {
  if (err) throw err;
  console.log("Connected to Database");

  //simple json record
	var document = {name:"David1", title:"About MongoDB1"};
  
	//insert record
	db.collection('test').insert(document, function(err, records) {
		if (err) throw err;
		console.log("Record added as "+records[0]._id);
		//After insertion, close it.
		db.close();
		return;
	});
});

```
Once fetched, insert into the weathertest Database.    

#### Display How Many Items
It should fetch the latest 24 items from the database, thus we should modify the code for fetching out 24 items.   

Edit routes/index.js:    

```
/* GET weatherlist page. */
router.get('/weatherlist', function(req, res) {
    var db = req.db;
    var collection = db.get('usercollection');

    collection.find({},{limit:24},function(e,docs){
        res.render('weatherlist', {
            "weatherlist" : docs
        });
    });

});

```

#### Deploy it on heroku
Via following commands we could setup a brand new APP on heroku:    

```
$ heroku login
$ cat web.js
// web.js
var express = require("express");
var logfmt = require("logfmt");
var app = express();

app.use(logfmt.requestLogger());

app.get('/', function(req, res) {
  res.send('Hello World!');
});

var port = Number(process.env.PORT || 5000);
app.listen(port, function() {
  console.log("Listening on " + port);
});
$ npm init
$ npm install express logfmt --save
$ cat package.json
  "engines": {
    "node": "0.10.x"
  }
$ cat Procfile 
web: node web.js
$ foreman start
$ chromium http://localhost:5000
$ git init
$ git add .
$ git commit -m "init"
$ git remote add heroku git@heroku.com:node-weather-app.git
$ git push heroku master

```
Now visit [http://node-weather-app.herokuapp.com](http://node-weather-app.herokuapp.com) you can see "Hello World!".     

When adding MongoDB add-ons, it says failed with following information:    

```
$ heroku addons:add mongolab
Adding mongolab on node-weather-app... failed
 !    Please verify your account to install this add-on plan
 !    For more information, see https://devcenter.heroku.com/categories/billing
 !    Verify now at https://heroku.com/verify

```
Apply the free account at[https://www.mongosoup.de/](https://www.mongosoup.de/), then login and create a new database plan, Next time if you want to view your database, simply open your browser and go to [https://controlpanel.mongosoup.de/](https://controlpanel.mongosoup.de/).     
Click the Databases, and select the database, then `show password`, it will shows you with the Database info, something like: 

```
Connection string:	mongodb://############:###########@dbs004.mongosoup.de/cc_KNoBTXxNbHhS

```

It seems the account failed, so I create a new account using another email, xxxxxxxxxx.    
This time the app's name is named nodeweatherapp
git@heroku.com:nodeweatherapp.git     
And this time we will use root account for uploading.    


        Git URL: git@heroku.com:nodeweather.gi

