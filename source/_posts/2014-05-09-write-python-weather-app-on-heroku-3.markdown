---
layout: post
title: "Write Python Weather APP on Heroku(3)"
date: 2014-05-09 19:12
comments: true
categories: python
---
### Database Introduction
#### Heroku Postgres Installation
Before using postgres, we have to install this add-ons, we call this step "attach Heroku POSTGRES to heroku application":   

```
$ heroku addons
python-weather-app has no add-ons.
$ heroku addons:add heroku-postgresql:dev
Adding heroku-postgresql:dev on python-weather-app... done, v7 (free)
Attached as HEROKU_POSTGRESQL_OLIVE_URL
Database has been created and is available
 ! This database is empty. If upgrading, you can transfer
 ! data from another database with pgbackups:restore.
Use `heroku addons:docs heroku-postgresql` to view documentation.
$ heroku addons | grep POSTGRES
heroku-postgresql:dev  HEROKU_POSTGRESQL_OLIVE

```
If you want to refer the documentation of heroku postgres, simply use following command:    

```
$ heroku addons:docs heroku-postgresql
Opening heroku-postgresql docs... done

```
A new browser window will be opened and you can view the help here.    
View the configuration of heroku postgres via:   

```
$ heroku pg:info
=== HEROKU_POSTGRESQL_OLIVE_URL (DATABASE_URL)
Plan:        Dev
Status:      Available
Connections: 0
PG Version:  9.3.4
Created:     2014-05-09 11:25 UTC
Data Size:   6.4 MB
Tables:      0
Rows:        0/10000 (In compliance)
Fork/Follow: Unsupported
Rollback:    Unsupported

```
10000 rows means, if we use 24 rows per day, then around 1 year this database will be fulfilled. But anyway, at the very beginning developing, we won't consider the latter problem.    
After you installed the postgre for around 5 minutes, you can use following commands for displaying your database:    

```
$ heroku pg:ps
 pid | state | source | running_for | waiting | query 
-----+-------+--------+-------------+---------+-------
(0 rows)

```
Now you can connect to pg via following command:    

```
$ heroku pg:psql
---> Connecting to HEROKU_POSTGRESQL_OLIVE_URL (DATABASE_URL)
psql (9.3.4)
SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
Type "help" for help.

d47ena4men35jn=> 

```
What for next?    
#### Local Postgres Installation
Install postgres via:    

```
$ sudo pacamn -S postgre
$ sudo -i -u postgres
[postgres@DashArch ~]$ initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'
# In another terminal, enable and start the service
$ sudo systemctl start postgresql
$ sudo systemctl enable postgresql

```
Now add current user into the postgres user:    

```
[postgres@DashArch ~]$ createuser --interactive
Enter name of role to add: Trusty
Shall the new role be a superuser? (y/n) y
# Now 'Trusty' as postgres user, can create the weatherData database. 
$ createdb weatherData

```
Basic user of postgres:    

```
$ psql -d weatherData   
psql (9.3.4)
Type "help" for help.

weatherData=# \help
......
weatherData=# \q
$ 

```

#### Connect Database In Python(Local Way)
Install the python packages:    

```
$ pip install psycopg2
$ pip freeze 
# Add the psycopg2 related line into the requirements.txt

```
A simple example on how to connect Database and view the content of the database:    

```
[Trusty@~]$ sudo -u postgres createuser jim
[Trusty@~]$ sudo -u postgres createdb testdb -O jim
[Trusty@~/code/herokuWeatherApp]$ source venv/bin/activate
(venv)[Trusty@~/code/herokuWeatherApp]$ python
Python 2.7.6 (default, Feb 26 2014, 12:07:17) 
[GCC 4.8.2 20140206 (prerelease)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import psycopg2
>>> import sys
>>> con = None
>>> con = psycopg2.connect(database='testdb', user='jim')
>>> cur = con.cursor()
>>> cur.execute('SELECT version()')   
>>> ver = cur.fetchone()
>>> print ver
('PostgreSQL 9.3.4 on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 4.8.2 20140206 (prerelease), 64-bit',)
>>> con.close()
>>> quit()
(venv)[Trusty@~/code/herokuWeatherApp]$ 

```

#### Connect Heroku Postgres
Now commit our modifications into heroku, and verify to see if we can really do some magic things with postgres:    

```
$ git add .
$ git commit -m "commit for postgres"
$ git push heroku master

```
Install a new library:   

```
$ pip install flask-sqlalchemy
$ pip freeze  # grep the line and add it into the requirement.txt

```
Promoting the URL to DATABASE_URL:    

```
$ heroku pg:promote HEROKU_POSTGRESQL_OLIVE_URL
Promoting HEROKU_POSTGRESQL_OLIVE_URL (DATABASE_URL) to DATABASE_URL... done

```
Then Add the following lines into genhtml.py:    

```
from flask.ext.sqlalchemy import SQLAlchemy
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ['DATABASE_URL']
db = SQLAlchemy(app)

##############FenGe_Line####################
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80))
    email = db.Column(db.String(120), unique=True)

    def __init__(self, name, email):
        self.name = name
        self.email = email

    def __repr__(self):
        return '<Name %r>' % self.name


```
Commit again and begin for verifying the database via CLI:    
Create a python interactive command window via:    

```
>>> from genhtml import db
>>> db.create_all()
>>> from genhtml import User
>>> user = User('John Doe', 'john.doe@example.com')
>>> db.session.add(user)
>>> db.session.commit()
>>> all_users =User.query.all()
>>> print all_users
[<Name u'John Doe'>]


```
Now we can see 1 record has been inserted into the database: 

```
[Trusty@~/code/herokuWeatherApp]$ heroku pg:info
=== HEROKU_POSTGRESQL_OLIVE_URL (DATABASE_URL)
Plan:        Dev
Status:      Available
Connections: 2
PG Version:  9.3.4
Created:     2014-05-09 11:25 UTC
Data Size:   6.5 MB
Tables:      1
Rows:        1/10000 (In compliance)
Fork/Follow: Unsupported
Rollback:    Unsupported

```
How to see the inserted data?    

```
$ heroku pg:psql
---> Connecting to HEROKU_POSTGRESQL_OLIVE_URL (DATABASE_URL)
psql (9.3.4)
SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
Type "help" for help.

d47ena4men35jn=> select current_database();
 current_database 
------------------
 d47ena4men35jn
(1 row)

d47ena4men35jn=> \dt
           List of relations
 Schema | Name | Type  |     Owner      
--------+------+-------+----------------
 public | user | table | yjusdsrpwpplxp
(1 row)

d47ena4men35jn=> \d user;
                                 Table "public.user"
 Column |          Type          |                     Modifiers                     
--------+------------------------+---------------------------------------------------
 id     | integer                | not null default nextval('user_id_seq'::regclass)
 name   | character varying(80)  | 
 email  | character varying(120) | 
Indexes:
    "user_pkey" PRIMARY KEY, btree (id)
    "user_email_key" UNIQUE CONSTRAINT, btree (email)

d47ena4men35jn=> SELECT * FROM public.user;
 id |   name   |        email         
----+----------+----------------------
  1 | John Doe | john.doe@example.com
(1 row)

```
We can use python's interface for add/delete records, drop tables, etc.     

