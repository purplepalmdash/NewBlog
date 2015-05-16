---
layout: post
title: "Write Python Weather APP on Heroku(4)"
date: 2014-05-09 22:50
comments: true
categories: python
---
### Local Database Sync
First fetch the remote database to localdb via following command:    

```
$ heroku pg:pull DATABASE_URL mylocaldb --app  python-weather-app

```
This command will pull down your database down and create a copy version locally. You can easily view all of the database via psql mylocaldb.    

As root, edit following files:    

```
# pwd
/var/lib/postgres/data
# vim postgresql.conf
listen_addresses = 'localhost'		# what IP address(es) to listen on;
					# comma-separated list of addresses;
					# defaults to 'localhost'; use '*' for all
					# (change requires restart)
port = 5432				# (change requires restart)
# vim pb_hba.conf
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
host    all             all             127.0.0.1/32            md5

```
After editing, save the file and restart the postgresql service. 
### Connecting to LocalDatabase
Following shows how to add/query the records. Now your environment could be totally debugged locally. 

```
>>> import psycopg2
>>> psycopg2.connect(database="mylocaldb",user="Trusty",password="",host="127.0.0.1",port="5432")
<connection object at 0x30f0cd0; dsn: 'dbname=mylocaldb user=Trusty password=xx host=127.0.0.1 port=5432', closed: 0>
>>> db_conn = 'postgresql+psycopg2://Trusty:@localhost/mylocaldb'
>>> app = Flask(__name__) 
>>> app.config['SQLALCHEMY_DATABASE_URI'] = db_conn
>>> db = SQLAlchemy(app)
>>> db.create_all()
>>> class User(db.Model):
...     id = db.Column(db.Integer, primary_key=True)
...     name = db.Column(db.String(80))
...     email = db.Column(db.String(120), unique=True)
...     def __init__(self, name, email):
...         self.name = name
...         self.email = email
...     def __repr__(self):
...         return '<Name %r>' % self.name
... 
>>> user = User('John Doe', 'john.doe@example.com')
>>> all_users=User.query.all()
>>> print all_users
[<Name u'John Doe'>]
>>> user1 = User('Jim Green', 'jim.green@english.com')
>>> db.session.add(user1)
>>> db.session.commit()

```
In genhtml.py we need to do corresponding changes in order to enable the local database.   
