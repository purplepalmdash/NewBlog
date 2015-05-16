---
layout: post
title: "Chinese Localization in ArchLinux"
date: 2013-11-04 09:39
comments: true
categories: Linux
---
1\. Soving the chinese Garbled in vim:

```
	set fileencodings=utf8,cp936,gb18030,big5
```

2\. Install chinese fonts:

```
	wqy-bitmapfont
	wqy-zenhei
	ttf-arphic-ukai
	ttf-arphic-uming
	ttf-fireflysung
	wqy-microhei（AUR中）
	wqy-microhei-lite（AUR中
```

3\. Copy files from linux to windows or other systems:     
You should do like following:    

```
mount /dev/sdc /mnt
#copy all of the pdf into the directory
	export LANG="zh_CN.utf8"
	export LC_ALL="zh_CN.utf8"
	mount /dev/sdc /mnt -t vfat -o iocharset=utf8
	cp /chinese/*** /YourDestination
```

4\. Using ftp for uploading files.    
In filezilla, Choose charset to gb2312, like following:

![charset](/images/charset.jpg "Charset gb2312")

5\. mount in specified charset

```
	mount -t vfat -o  iocharset=gb2312 -o  codepage=936 /dev/sdc /mnt
```

6\. Changing existing names:

```
	convmv -f UTF-8 -t GBK --notest utf8编码的文件名
```



