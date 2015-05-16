---
layout: post
title: "Tips on 30Days30Skills"
date: 2014-11-22 16:28
comments: true
categories: web
---
This series is the note for learning 30days30skills, the origin web pages could be found at:     
[http://segmentfault.com/a/1190000000349384](http://segmentfault.com/a/1190000000349384)    
All of these operations should be done under MACOS rather than linux.    

### Day 1 - bower
First install nodejs from following position:     
[nodejs.org/download/](nodejs.org/download/)    
Git could be installed from APPStore.    
Set npm proxy before you do everything, cause I operate under the proxy based network:    

```
npm config set proxy http://xxx.xxx.xxx.xx:xxxx
npm config set https-proxy http://xxx.xxx.xxx.xx:xxxx

```
Install bower:    

```
$ set2383 #(For setting the proxy)
sudo npm install -g bower

```
Using bower for install the jquery packages:    

```
$ pwd
/Users/Trusty/Code/jQuery
$ set2383 #(For setting the proxy)
$ bower install jquery

```
Query the installed package information(This need to be done after you set the git configuration on proxy, because I worked under the proxy):     

```
Yosemite:jQuery Trusty$ bower list
bower check-new     Checking for new versions of the project dependencies..
jQuery /Users/Trusty/Code/jQuery
└── jquery#2.1.1 extraneous

```
Uninstall packages via:    

```
Yosemite:jQuery Trusty$ bower uninstall jquery
bower uninstall     jquery
Yosemite:jQuery Trusty$ ls
bower_components	simpleHtml.html		simpleHtml.html~
Yosemite:jQuery Trusty$ tree
.
├── bower_components
├── simpleHtml.html
└── simpleHtml.html~

1 directory, 2 files

```
use `bower init` for creating packages:    

```
Yosemite:jQuery Trusty$ bower init
? name: blog
? version: 0.0.1
? description:
? main file:
? what types of modules does this package expose?: globals
? keywords: blog written
? authors: xxx <xxx@gmail.com>
? license: MIT
? homepage:
? set currently installed components as dependencies?: Yes
? add commonly ignored files to ignore list?: Yes
? would you like to mark this package as private which prevents it from being accidentally published to the registry?: No

{
  name: 'blog',
  version: '0.0.1',
  authors: [
    'xxx <xxx@gmail.com>'
  ],
  moduleType: [
    'globals'
  ],
  keywords: [
    'blog',
    'written'
  ],
  license: 'MIT',
  ignore: [
    '**/.*',
    'node_modules',
    'bower_components',
    'test',
    'tests'
  ]
}

```
Then if you installed new packages, it will automatically calculate the dependencies and write to the json.

```
Yosemite:jQuery Trusty$ bower install bootstrap --save

```
### Day 2 AngularJS
#### Issue
Seems all of the tests has been passed expect the last one, it complains:    

```
Error: error:areq
Bad Argument
Argument 'BookCtrl' is not a function, got undefined

```
The reason is because the global constructor function is not allowed to use and use it with ng-controller since Angular's version upper than 1.3.x.     
#### Solution
Specify the AngularJS version when installing it.    

```
$ bower list
bower check-new     Checking for new versions of the project dependencies..
AngularJS /Users/Trusty/Code/30Days/AngularJS
├── angular#1.3.3 extraneous (1.3.4-build.3611+sha.e9b9421 available)
└─┬ bootstrap#3.3.1 extraneous
  └── jquery#2.1.1
Yosemite:AngularJS Trusty$ bower install "angular#<1.3"
bower angular#<1.3          not-cached https://github.com/angular/bower-angular.git#<1.3
bower angular#<1.3             resolve https://github.com/angular/bower-angular.git#<1.3
bower angular#<1.3            download https://github.com/angular/bower-angular/archive/v1.2.27.tar.gz
bower angular#<1.3             extract archive.tar.gz
bower angular#<1.3            resolved https://github.com/angular/bower-angular.git#1.2.27
bower angular#<1.3             install angular#1.2.27

```
Now re-view the index5.html in the browser, everything will be OK.    
#### Another Solution
Modify the code into following:    

``` html
<!DOCTYPE html>
<html ng-app>
<head>
    <title>Bookshop - Your Online Bookshop</title>
    <link rel="stylesheet" type="text/css" href="bower_components/bootstrap/dist/css/bootstrap.min.css">
</head>
<body>

	<div class="container" ng-controller="BookCtrl">
        <h2>Your Online Bookshop</h2>
	<input type="search" ng-model="criteria">
        <ul class="unstyled">
            <li ng-repeat="book in books | filter:criteria | orderBy :'name'">
                <span>{{book.name}} written by {{book.author | uppercase}}</span>
            </li>
        </ul>
    </div>

    <script type="text/javascript" src="bower_components/angular/angular.min.js"></script>

<script>
function BookCtrl($scope){
        $scope.books = [
                {'name': 'Effective Java', 'author':'Joshua Bloch'},
                {'name': 'Year without Pants', 'author':'Scott Berkun'},
                { 'name':'Confessions of public speaker','author':'Scott Berkun'},
                {'name':'JavaScript Good Parts','author':'Douglas Crockford'}
        ]
}
angular.module('ng').config(function($controllerProvider) {
	$controllerProvider.allowGlobals();
});
</script>
</body>
</html>


```
I don't know how to set the global for seperated js file, but the above example works.   
