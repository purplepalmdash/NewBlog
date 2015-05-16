---
layout: post
title: "Cut your pdf into 6 inch in Linux"
date: 2013-11-04 16:06
comments: true
categories: Linux
---
###Preparation
Yaourt briss will show the following result:

```
	1 aur/briss 0.9-2 (58)
	    Java tool to crop pages of PDF documents to one or more regions selected with a GUI.
	==> Enter n° of packages to be installed (ex: 1 2 3 or 1-3)
```

Install it and now we will going to cut our pdfs.
###Cutting
First you can manually cut your pdf, and set it to fit your own size.Simply input "briss" then you can got a window for your operation.   
Or via command line:

```
	$ briss -s Your_pdf.pdf
```

The result is listed as following: 

![resized](/images/resized.jpg "resized image")

###Tips
How to resize your image to fixed size:

```
	$ convert -resize 1000x from.jpg to.jpg
```

