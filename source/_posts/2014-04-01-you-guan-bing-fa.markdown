---
layout: post
title: "有关并发"
date: 2014-04-01 19:07
comments: true
categories: app2e
---
app2e中有几个很好的关于并发实现的例子，这里加以详细解析。<br />
###简单的echo服务器
所谓echo服务器就是将客户端的输入简单的通过socket回送回来。代码实现如下：<br />

```c echoserver.c
#include <csapp.h>

void echo(int connfd);

int main(int argc, char **argv)
{
	int listenfd, connfd, port, clientlen;
	struct sockaddr_in clientaddr;
	struct hostent *hp;
	char *haddrp;

	if(argc != 2) {
		fprintf(stderr, "usage: %s <port>\n", argv[0]);
		return 1;
	}
	port = atoi(argv[1]);

	listenfd = Open_listenfd(port);
	while(1) {
		clientlen = sizeof(clientaddr);
		connfd = Accept(listenfd, (SA *)&clientaddr, &clientlen);

		/* determin the domain name and IP address of the client */
		hp = Gethostbyaddr((const char*)&clientaddr.sin_addr.s_addr, 
				sizeof(clientaddr.sin_addr.s_addr), AF_INET);
		haddrp = inet_ntoa(clientaddr.sin_addr);
		printf("server conected to %s (%s)\n", hp->h_name, haddrp);
		echo(connfd);
		Close(connfd);
	}
	return 0;
}

void echo(int connfd)
{
	size_t n;
	char buf[MAXLINE];
	rio_t rio;

	Rio_readinitb(&rio, connfd);
	while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0) {
		printf("server received %d bytes\n", n);
		Rio_writen(connfd, buf, n);
	}
}

```
从代码来看，这是一个很典型的socket通信的例子。连接一旦建立成功，server段会打印出client端的IP地址，并一直在echo程序中晃荡。因为echo()中有while()函数会一直等着从connfd文件描述符读入输入行。当得到来自socket fd的输入时，会打印出接收到的字符个数，并将其写入到socket文件描述符中，由此client段会得到回显字符。<br />
###利用进程实现并发
上面的简单echo服务器是没法接受一个以上的连接的。因此我们写出echo服务器的第二版，利用子进程实现echo服务器。<br />

```c echoserverp.c
/* 
 * echoserverp.c - A concurrent echo server based on processes
 */
/* $begin echoserverpmain */
#include "csapp.h"
void echo(int connfd);

void sigchld_handler(int sig) //line:conc:echoserverp:handlerstart
{
    while (waitpid(-1, 0, WNOHANG) > 0)
	;
    return;
} //line:conc:echoserverp:handlerend

int main(int argc, char **argv) 
{
    int listenfd, connfd, port;
    socklen_t clientlen=sizeof(struct sockaddr_in);
    struct sockaddr_in clientaddr;

    if (argc != 2) {
	fprintf(stderr, "usage: %s <port>\n", argv[0]);
	exit(0);
    }
    port = atoi(argv[1]);

    Signal(SIGCHLD, sigchld_handler);
    listenfd = Open_listenfd(port);
    while (1) {
	connfd = Accept(listenfd, (SA *) &clientaddr, &clientlen);
	if (Fork() == 0) { 
	    Close(listenfd); /* Child closes its listening socket */
	    echo(connfd);    /* Child services client */ //line:conc:echoserverp:echofun
	    Close(connfd);   /* Child closes connection with client */ //line:conc:echoserverp:childclose
	    exit(0);         /* Child exits */
	}
	Close(connfd); /* Parent closes connected socket (important!) */ //line:conc:echoserverp:parentclose
    }
} 

void echo(int connfd)
{
	size_t n;
	char buf[MAXLINE];
	rio_t rio;

	Rio_readinitb(&rio, connfd);
	while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0) {
		printf("server received %d bytes\n", n);
		Rio_writen(connfd, buf, n);
	}
}


/* $end echoserverpmain */

```
编译和运行命令如下：<br />

```
	$ gcc -o echoserverp echoserverp.c -lcsapp -lpthread
	$ ./echoserverp 3344
	$ ./echoclient localhost 3344

```
在多个终端上执行完./echoclient localhost 3344后，我们可以用ps -ef | grep echoserverp来检查当前系统中的进程个数:<br />

```
	$ ps -ef | grep echoserverp
	Trusty     30404  8497  0 17:19 pts/9    00:00:00 ./echoserverp 3344
	Trusty     30651 30404  0 17:19 pts/9    00:00:00 ./echoserverp 3344
	Trusty     31174 30404  0 17:20 pts/9    00:00:00 ./echoserverp 3344

```
这里看到，在有3个client端连接时，存在3个echoserverp运行实例。<br />	

实现的关键在于：<br />
1. 使用信号, SIGCHLD用于回收僵死进程。
2. Fork()函数创建子进程。
3. 创建完子进程后，父进程需要关闭已经建立的socket连接。而子进程则需要关闭它的监听描述符。

优缺点比较：<br />
父子进程共享文件表，但是不共享用户地址空间。使得一个进程不可能不小心覆盖到另一个进程的虚拟存储器。但是独立的地址空间使得进程共享状态信息变得困难，它们需要用IPC来显示通信。而且进程通常比较慢，因为进程控制和IPC的开销很高。IPC,进程间通信。<br />
###基于I/O多路复用的并发编程


```c selectecho.c
/* $begin select */
#include "csapp.h"
void echo(int connfd);
void command(void);

int main(int argc, char **argv) 
{
    int listenfd, connfd, port;
    socklen_t clientlen = sizeof(struct sockaddr_in);
    struct sockaddr_in clientaddr;
    fd_set read_set, ready_set;

    if (argc != 2) {
	fprintf(stderr, "usage: %s <port>\n", argv[0]);
	exit(0);
    }
    port = atoi(argv[1]);
    listenfd = Open_listenfd(port);  //line:conc:select:openlistenfd

    FD_ZERO(&read_set);              /* Clear read set */ //line:conc:select:clearreadset
    FD_SET(STDIN_FILENO, &read_set); /* Add stdin to read set */ //line:conc:select:addstdin
    FD_SET(listenfd, &read_set);     /* Add listenfd to read set */ //line:conc:select:addlistenfd

    while (1) {
	ready_set = read_set;
	Select(listenfd+1, &ready_set, NULL, NULL, NULL); //line:conc:select:select
	if (FD_ISSET(STDIN_FILENO, &ready_set)) //line:conc:select:stdinready
	    command(); /* Read command line from stdin */
	if (FD_ISSET(listenfd, &ready_set)) { //line:conc:select:listenfdready
	    connfd = Accept(listenfd, (SA *)&clientaddr, &clientlen);
	    echo(connfd); /* Echo client input until EOF */
	    Close(connfd);
	}
    }
}

void command(void) {
    char buf[MAXLINE];
    if (!Fgets(buf, MAXLINE, stdin))
	exit(0); /* EOF */
    printf("%s", buf); /* Process the input command */
}

void echo(int connfd)
{
	size_t n;
	char buf[MAXLINE];
	rio_t rio;

	Rio_readinitb(&rio, connfd);
	while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0) {
		printf("server received %d bytes\n", n);
		Rio_writen(connfd, buf, n);
	}
}

/* $end select */

```
这个例子测试时需要注意的是，当客户端有连接时，终端输入将失效。一个更好的解决方案是使用更细粒度的多路复用，服务器每次循环回送一个文本行。
