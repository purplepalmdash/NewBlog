---
layout: post
title: "Write Python Weather APP on Heroku(5)"
date: 2014-05-10 09:02
comments: true
categories: python
---
In fact this is a migration from sqlite3 to postgresql.    
### View the historical sqlite3
We will refer to our own design of database. First fetch the data file, this is a sqlite3 file, so we use sqlite3 to view its structure.   

```
$ sqlite3  
SQLite version 3.8.4.3 2014-04-03 16:53:12
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .open ./weather.db
sqlite> .tables
foo
sqlite> .schema foo
CREATE TABLE foo (d_temper integer, d_humi integer, d_pm10 integer, d_pm25 real, d_time timestamp);

```
Although sqlite3 is supported on heroku, we'd better use heroku's suggestion, to use postgre for storing out database.  
### Create Database In Postgres
####Datatime selection:     
Postgres provides a very fantanstic way for handling the datatime, it supports the timezone, comparing to GAE's database, this feature will let us get the current time based on timezone. So we did the following tests:    

```
# CREATE TABLE my_tbl (
mylocaldb(# my_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
mylocaldb(# CHECK(EXTRACT(TIMEZONE FROM my_timestamp) = '0')
mylocaldb(# );
CREATE TABLE
mylocaldb=# \dt my_tbl
        List of relations
 Schema |  Name  | Type  | Owner 
--------+--------+-------+-------
 public | my_tbl | table | Trusty
(1 row)

```
When we want to insert the datatime into table 'my_tbl', simply do following:    

```
mylocaldb=# SET timezone = 'UTC';
SET
mylocaldb=# INSERT INTO my_tbl (my_timestamp) VALUES (NOW());
INSERT 0 1

```
And for querying out the inserted records, we do following:    

```
mylocaldb=# select * from public.my_tbl
;
         my_timestamp          
-------------------------------
 2014-05-10 01:39:52.87532+00
 2014-05-10 01:42:44.130269+00
(2 rows)

mylocaldb=# SET timezone='Asia/Shanghai';
SET
mylocaldb=# select * from public.my_tbl
mylocaldb-# ;
         my_timestamp          
-------------------------------
 2014-05-10 09:39:52.87532+08
 2014-05-10 09:42:44.130269+08
(2 rows)

mylocaldb=# SET timezone='America/Los_Angeles';
SET
mylocaldb=# select * from public.my_tbl;
         my_timestamp          
-------------------------------
 2014-05-09 18:39:52.87532-07
 2014-05-09 18:42:44.130269-07
(2 rows)

```
We can see the output formats depends on our "timezone" value.     
#### Select Other Data Formats
We listed following table for describing the Data we inserted:    
Timestamp       integer     integer    integer    integer    
Insert_Time     Temperature Humidity   PMTen       PMTwoFive    

Thus the sql sentense is as following: 

```
mylocaldb=# CREATE TABLE weather (
mylocaldb(# my_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
mylocaldb(# Temperature ^C
mylocaldb=# CREATE TABLE weather (
mylocaldb(# Insert_Time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
mylocaldb(# Temperature integer,
mylocaldb(# Humidity integer,
mylocaldb(# PMTen integer,
mylocaldb(# PMTwoFive integer,
mylocaldb(#  CHECK(EXTRACT(TIMEZONE FROM Insert_Time) = '0'));

```
Check the tables:    

```
mylocaldb=# \dt
        List of relations
 Schema |  Name   | Type  | Owner 
--------+---------+-------+-------
 public | my_tbl  | table | Trusty
 public | user    | table | Trusty
 public | weather | table | Trusty
(3 rows)

```
Insert one record:    

```
mylocaldb=# INSERT INTO weather (Insert_Time, Temperature, Humidity, PMTen, PMTwoFive) VALUES(NOW(), 25, 80, 150, 75);
INSERT 0 1

```
Displaying the inserted record:    

```
mylocaldb=# SET timezone='Asia/Shanghai';
SET
mylocaldb=# select * from public.weather;
          insert_time          | temperature | humidity | pmten | pmtwofive 
-------------------------------+-------------+----------+-------+-----------
 2014-05-10 10:38:27.276043+08 |          25 |       80 |   150 |        75
(1 row)

```
#### Database Operation
We need to create just once database, So this function should be Check_Or_Create().     
We need to insert records, so Insert_Record() should be written.    
Other Operation, modification or delete shouldn't care at the very beginning.    
We will use a new file for recording all of the function.    

The code for Create and Insert record into weather table is listed as following:    

```py database.py
from sqlalchemy import create_engine
from sqlalchemy import MetaData, Column, Table, ForeignKey
from sqlalchemy import Integer, String, DateTime
import datetime

# Create the engine for connecting the local database
# How to connect the remote engine, heroku postgres? 
# Yes, it's possible. The DATABASE_URL environment variable provided by heroku fits perfectly as argument for create_engine. Behind the scene, it's a postgresql database, which is perfectly handled by sqlalchemy.
# 
# The way to do it may vary depending on the framework you use, but there shouldn't be any difficulty.

engine = create_engine('postgresql+psycopg2://Trusty:@localhost:5432/mylocaldb',echo=True)
metadata=MetaData(bind=engine)

# Definition of the weather table
weather_table=Table('weather',metadata,
	Column('Insert_Time', DateTime(timezone=True),primary_key=True),
	Column('Temperature', Integer),
	Column('Humidity', Integer),
	Column('PmTen', Integer),
	Column('PmTwoFive', Integer),
)

# Create the table in mylocaldb
metadata.create_all(checkfirst=True)

# The actual SQL Language
#CREATE TABLE weather (
#	"Insert_Time" TIMESTAMP WITH TIME ZONE NOT NULL, 
#	"Temperature" INTEGER, 
#	"Humidity" INTEGER, 
#	"PmTen" INTEGER, 
#	"PmTwoFive" INTEGER, 
#	PRIMARY KEY ("Insert_Time")
#)

# mylocaldb=# select * from public.weather;
#  Insert_Time | Temperature | Humidity | PmTen | PmTwoFive 
# -------------+-------------+----------+-------+-----------
# (0 rows)

# Record Insertion
# First generate an insertion sentense:
ins = weather_table.insert()
#>>> str(ins)
#'INSERT INTO weather ("Insert_Time", "Temperature", "Humidity", "PmTen", "PmTwoFive") VALUES (%(Insert_Time)s, %(Temperature)s, %(Humidity)s, %(PmTen)s, %(PmTwoFive)s)'

ins = weather_table.insert().values(Insert_Time=datetime.datetime.utcnow(), Temperature=25, Humidity=75, PmTen=100, PmTwoFive=55)

#>>> str(ins)
#'INSERT INTO weather ("Insert_Time", "Temperature", "Humidity", "PmTen", "PmTwoFive") VALUES (%(Insert_Time)s, %(Temperature)s, %(Humidity)s, %(PmTen)s, %(PmTwoFive)s)'
#
#>>> ins.compile().params
#{'PmTen': 100, 'PmTwoFive': 55, 'Temperature': 25, 'Insert_Time': datetime.datetime(2014, 5, 10, 5, 58, 21, 677234), 'Humidity': 75}

# Connect to engine and execute. 
conn = engine.connect()
# >>> conn
# <sqlalchemy.engine.base.Connection object at 0x2715890>
result = conn.execute(ins)
# View result in psql
# mylocaldb=# select * from public.weather;
#           Insert_Time          | Temperature | Humidity | PmTen | PmTwoFive 
# -------------------------------+-------------+----------+-------+-----------
#  2014-05-10 05:58:21.677234+08 |          25 |       75 |   100 |        55

```
The critical functions has been pointed out in the above python file. Now we will consider how to run these functions at background. This will lead to next topic, "Run multiple process in a single Heroku dyno".        
