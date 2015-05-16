---
layout: post
title: "Enable Apache2 Redirect"
date: 2015-01-22 04:02
comments: true
categories: web
---
### Problem
Want to redirect from `http://xxx/ ` to `http://xxx/a/b`    
### Solution
Change the configuration file of the `/etc/apache2/sites-enabled/000-default`, enable the  `RedirectMatch`:    

```
	# For forwarding all of the request to '/' TO '/bin/view'
 	RedirectMatch ^/$ /a/b

```
Restart the service of apache2 then everything goes OK.    
