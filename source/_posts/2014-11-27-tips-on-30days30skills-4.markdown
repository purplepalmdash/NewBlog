---
layout: post
title: "Tips on 30Days30Skills(4)"
date: 2014-11-27 16:49
comments: true
categories: web
---
### Day 9 - TextBlob
Installation:    

```
Yosemite:TextBlob Trusty$ mkdir myapp
Yosemite:TextBlob Trusty$ cd myapp/
Yosemite:myapp Trusty$ virtualenv venv --python=python2.7
Running virtualenv with interpreter /usr/bin/python2.7
New python executable in venv/bin/python
Installing setuptools, pip...done.
Yosemite:myapp Trusty$ . venv/bin/activate
(venv)Yosemite:myapp Trusty$ pip install textblob
$ pip install -U textblob
$ python -m textblob.download_corpora

```
After adding the textblob, create flask:     

```
$ pip install flask
$ vim app.py
$ mkdir templates
$ touch templates/index.html

```
Modify the app.py for listening on all of the ip addresses:    

```
if __name__ == "__main__":
    app.run(host='0.0.0.0',debug=True)

```
Then `python app.py` could get you to the website and run your apps.    

The analyze code is listed as following:    

```
            $.get('/api/v1/sentiment/'+input,function(result){

                if(result.polarity < 0.0){

                    $('#result').addClass("alert alert-danger")   .text(input);
                } else if( result.polarity >= 0.0 && result.polarity <= 0.5){
                    $('#result').addClass("alert alert-warning").text(input);
                }else{
                    $('#result').addClass("alert alert-success").text(input);
                }

            })

```
You could easily update the apps to your rhc.    
### Day 10 - PhoneGap
#### Android
Install steps:    

```
$ sudo npm install -g phonegap
$ sudo npm install -g cordova
$ phonegap create reader --id io.reader --name Reader30
$ sudo android

```
`sudo android` is for installing the android SDK, we have to select revision 19 for phonegap currently support 19.    

```
$ cordova platform add android
$ sudo pacman -S apache-ant
$ phonegap run android

```
Now you could see a screen which displayed "Device Ready".     
Install some plugins for accessing the equipment:    

```
cordova plugin add org.apache.cordova.geolocation
cordova plugin add org.apache.cordova.dialogs

```
Edit steps:    

```
$ vim www/index.html 	# Add front page
$ rm -f www/js/index.js
$ cp -r ../example/30technologies30days-mobile-app/www/js/vendor ./www/js
$ cp -r ../example/30technologies30days-mobile-app/www/css/vendor ./www/css
$ vim www/js/app.js
$ vim www/index.html	# Add form
$ vim www/js/app.js

```
Now run `phonegap run android` you could see the app runs on your android emulator.    


#### IOS
In ios, we could use following command for installing the ios specified resources.   

```
(venv)Yosemite:PhoneGap Trusty$ cd reader/
(venv)Yosemite:reader Trusty$ cordova platform add ios
$ sudo npm install -g ios-deploy
$ sudo npm install -g ios-sim
$ phonegap run ios

```
