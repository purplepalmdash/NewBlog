---
layout: post
title: "Write Python Weather APP on Heroku(11)"
date: 2014-05-13 21:00
comments: true
categories: python
---
### Draw Flot Picture
Since the article is mainly on writing apps, I don't want to spend much time on how to use javascript or flot for drawing picture.    
Simply checkout the code on github, you will see the code which is used for retrieving the data and start drawing plot pictures.    
### Fetching 24-hours Data
Fetching 24 latest records from the postgres database, and then add them into the chart, chart then has been sent to simplejson which used for updating the flot picture locally .       

```py genhtm.py
@app.route('/ajax/24hours/')
# ajax updateing for 24-hour data
def TwentyFourHours():
    # Here we will visit postgres for retrieving back the last 24 hours' data
    # Local version
    # engine = create_engine('postgresql+psycopg2://Trusty:@localhost:5432/mylocaldb', echo=True)
    # Heroku Version
    db_conn = os.environ['DATABASE_URL']
    engine = create_engine(db_conn)
    # Engine selection
    metadata=MetaData(bind=engine)
    weather_table=Table('weather',metadata,
        Column('Insert_Time', DateTime(timezone=True),primary_key=True),
        Column('Temperature', Integer),
        Column('Humidity', Integer),
        Column('PmTen', Integer),
        Column('PmTwoFive', Integer),
    )
    s = select([weather_table]).order_by(weather_table.c.Insert_Time.desc()).limit(24)
    conn = engine.connect()
    result = conn.execute(s)
    chart = []
    for row in result:
        # row[0], datetime; 
        # row[1], Temperature;
        # row[2], Humidity;
        # row[3], PM10;
        # row[4], PM2.5; 

        ###  append row[x] into the char ###
        # chart.append({
        chart.insert(0, {
            "label": (row[0] + timedelta(hours = 8)).strftime("%H:%M"),
            "value": row[1],
            "humi_value": row[2],
            "pm25_value": row[4],
            "pm10_value": row[3]
            })

    jsonStr = simplejson.dumps({
        # This is char, will be used in script.js
        "chart" :{
            # tooltip is used by the jQuery chart:
            "tooltip"   : "Temperature at %1: %2 degree",
            # humi_tooltip is used for jQuery chart for humidity:
            "humi_tooltip" : "Humidity at %1: %2 \%",
            "pm25_tooltip" : "PM2.5 at %1: %2 ug/m(3)",
            "pm10_tooltip" : "PM10 at %1: %2 ug/m(3)",
            "data"      : chart
            },
        # This is "downtime" will be used in script.js
             "downtime"  : getDowntime(1)
        })

    return jsonStr;

```
The periodic task which runs in `tasks.py` will fetching the data from the python api and the webpage, then insert them into the postgres database, so here in 24-hours' function we just get them out and fill in the flot picture.      
### Daily Data
Daily data shall be generated via calculating them at the mid-night, that is, at the beginning of a brand new day, we will calculate out the last day's average data.    
The code is implemented in `tasks.py` as a crontab task, the code is listed as following:    

```py tasks.py
# Every Day we will run a periodly work which will calculate 
# the average temperature/humidity/pm2.5/pm10 task, and store
# it into the daily database, thus we have to define new Database
# here and insert data into.
# Beijing is locate at east 8 zone, thus 16:12 + 8 hour = 24:12
# At every mid-night(24:12) it will caculate the average value for
# the past 24 hours. 
@periodic_task(run_every=crontab(hour=16, minute=12))
def OneDayHandler():
    # First Get the last 24 hours' data set
    # Local Engine
    # engine = create_engine('postgresql+psycopg2://Trusty:@localhost:5432/mylocaldb',echo=True)
    # Heroku Engine
    db_conn = environ['DATABASE_URL']
    engine = create_engine(db_conn)
    metadata=MetaData(bind=engine)
    # Definition of the weather table
    weather_table=Table('weather',metadata,
    	Column('Insert_Time', DateTime(timezone=True),primary_key=True),
    	Column('Temperature', Integer),
    	Column('Humidity', Integer),
    	Column('PmTen', Integer),
    	Column('PmTwoFive', Integer),
    )
    # Get last 24 records, If we suppose there are truely 24 records in last 24 hours, we can enable this sentense. But sometimes, this will be wrong. 
    s = select([weather_table]).order_by(weather_table.c.Insert_Time.asc()).limit(24)
    conn = engine.connect()
    results = conn.execute(s)

    # Temperature
    totTemperature = 0
    avgTemperature = 0
    # Humidity
    totHumidity = 0
    avgHumidity = 0
    # PM2.5
    totPm25 = 0
    avgPm25 = 0
    # PM10
    totPm10 = 0
    avgPm10 = 0

    records_number = 0 
    for item in results:
        totTemperature += item[1]
        totHumidity += item[2]
        totPm25 += item[4]
        totPm10 += item[3]
        records_number += 1

    if records_number>0:
        avgTemperature = totTemperature/records_number
        avgHumidity = totHumidity/records_number
        avgPm25 = totPm25/records_number
        avgPm10 = totPm10/records_number

    # Definition of the avg_eather table
    avg_metadata = MetaData(bind=engine)
    avg_weather_table=Table('avg_weather',avg_metadata,
    	Column('avg_Insert_Time', DateTime(timezone=True),primary_key=True),
    	Column('avg_Temperature', Integer),
    	Column('avg_Humidity', Integer),
    	Column('avg_PmTen', Integer),
    	Column('avg_PmTwoFive', Integer),
    )
    # Create table in db
    avg_metadata.create_all(checkfirst=True)
    # Create insert sentense
    avg_ins = avg_weather_table.insert()
    # Really insert
    avg_ins = avg_weather_table.insert().values(avg_Insert_Time=datetime.utcnow(), avg_Temperature = avgTemperature, avg_Humidity = avgHumidity, avg_PmTen = avgPm10, avg_PmTwoFive = av
gPm25)
    # Connect to engine and execute
    avg_conn = engine.connect()
    avg_conn.execute(avg_ins)

    return 1

```
We defined a new table named avg_weather, and at the mid-night we will retrieve the latest 24 records, calculating their average value, then insert them into the aver_weather table.     
### Displaying Daily Data
The main procedure is mainly like in 24-hours datas, but notice we are select from avg_weather, and we only select 7 items.     
30-days data is very simple, change the day from 7 to 30, then you can see the monthly data.    
### Write Testing Interface
We hope we can manually test the functions via web. So we added following testing APIs in genhtml.py:    

```py genhtml.py
@app.route('/test/fetch/')
def fetch():
    fetch_and_store_data()
    return "Fetching Test Done!!!";

@app.route('/test/gen/')
def generateOneDay():
    OneDayHandler()
    return "Generate Test Done!!!";

```
If we visit http://Your_app_address/test/fetch, the program will fetch back the data.  And for http://Your_app_address/test/gen, the daily average data will be generated.    

Next Chapter is the last one. We simply paste the screenshots of the APP.    
