---
layout: post
title: "Use Eclipse and C/C++ to develop on Beaglebone"
date: 2013-11-14 10:55
comments: true
categories: Linux Beaglebone
---
###Local Development on Beaglebone board.
On Beagle to verify local development:
{% codeblock test.cpp-test.cpp %}
	#include <iostream>
	using namespace std;
	
	
	int main()
	{
		cout<<"Hello Beagle World!"<<endl;
		return 0;
	}
{% endcodeblock %}
Compile and run:

```
	$ g++ -o test test.cpp
	$ ./test
	Hello Beagle World!
```

###Using Cross-compiler for developing applications for Beaglebone
Launch eclipse, then install new software via help-> Install new software, make sure installed CDT. then we will install RSE.    

```
	$ pwd
	/home/Trusty/.eclipse/org.eclipse.platform_4.3.0_1543616141_linux_gtk_x86_64/plugins
	cp -ar /home/Trusty/Downloads/RSE/eclipse/features/* ./
	cd ../plugins/
	cp -ar /home/Trusty/Downloads/RSE/eclipse/plugins/* ./
```

This installed the RSE(Remote System Explorer). We can use it for browsing the remote beaglebone board.     

