---
layout: post
title: "Reading Digests for APP2E"
date: 2014-04-01 10:50
comments: true
categories: app2e
---
###Preparation
Download the files from the student's website of app2e via:<br />

```
	wget http://csapp.cs.cmu.edu/public/ics2/code.tar
	tar xvf code.tar

```
Start building the static libs and copy it to system library:<br />

```
	[Trusty@XXXyyy lib]$ pwd
	/home/Trusty/code/app2e/practise/lib
	[Trusty@XXXyyy lib]$ cp /home/Trusty/code/app2e/code/src/csapp.c  .
	[Trusty@XXXyyy lib]$ cp /home/Trusty/code/app2e/code/include/csapp.h  .
	[Trusty@XXXyyy lib]$ gcc -c -o csapp.o csapp.c 
	[Trusty@XXXyyy lib]$ ar rcs libcsapp.a csapp.o
	[Trusty@XXXyyy lib]$ sudo cp libcsapp.a  /usr/lib/
	[Trusty@XXXyyy lib]$ sudo cp csapp.h  /usr/include/

```
Now you can directly use libcssapp.a in your own files:<br />

```c test.c
#include <csapp.h>

int main(int argc, char **argv)
{
	int n;
	rio_t rio;
	char buf[MAXLINE];
	return 0;
}

```
Compile the file via:<br />

```
	gcc -o test test.c

```
###Rio

```c cpfile.c
#include <csapp.h>

int main(int argc, char **argv)
{
	int n;
	rio_t rio;
	char buf[MAXLINE];

	Rio_readinitb(&rio, STDIN_FILENO);
	while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0)
	{
		Rio_writen(STDOUT_FILENO, buf, n);
	}
	return 0;
}

```
Compile the file via:<br />

```
	gcc -o cpfile cpfile.c  -lcsapp -lpthread

```
Run the app via:<br />

```
	./cpfile<cpfile.c

```
This will print the cpfile.c content on the stdout screen.
