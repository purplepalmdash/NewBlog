---
layout: post
title: "有关并发(2)"
date: 2014-04-02 15:52
comments: true
categories: csapp
---
I/O多路技术可以作为并发事件驱动(event-driver)程序的基础。事件驱动中，流作为某种事件的结果前进。逻辑流可以被转化为状态机。<br />
在服务器中，我们可以用I/O多路复用，借助select函数，检测输入事件的发声。当每个已连接描述符准备好可读时，服务器为相应的状态机执行状态转移。在例子中，就是从描述符读入和写回一个文本行。<br />
###并发事件驱动服务器
首先看代码:<br />

```c echoservers.c
	/* 
	 * echoservers.c - A concurrent echo server based on select
	 */
	/* $begin echoserversmain */
	#include "csapp.h"
	
	typedef struct { /* represents a pool of connected descriptors */ //line:conc:echoservers:beginpool
	    int maxfd;        /* largest descriptor in read_set */   
	    fd_set read_set;  /* set of all active descriptors */
	    fd_set ready_set; /* subset of descriptors ready for reading  */
	    int nready;       /* number of ready descriptors from select */   
	    int maxi;         /* highwater index into client array */
	    int clientfd[FD_SETSIZE];    /* set of active descriptors */
	    rio_t clientrio[FD_SETSIZE]; /* set of active read buffers */
	} pool; //line:conc:echoservers:endpool
	/* $end echoserversmain */
	void init_pool(int listenfd, pool *p);
	void add_client(int connfd, pool *p);
	void check_clients(pool *p);
	/* $begin echoserversmain */
	
	int byte_cnt = 0; /* counts total bytes received by server */
	
	int main(int argc, char **argv)
	{
	    int listenfd, connfd, port; 
	    socklen_t clientlen = sizeof(struct sockaddr_in);
	    struct sockaddr_in clientaddr;
	    static pool pool; 
	
	    if (argc != 2) {
		fprintf(stderr, "usage: %s <port>\n", argv[0]);
		exit(0);
	    }
	    port = atoi(argv[1]);
	
	    listenfd = Open_listenfd(port);
	    init_pool(listenfd, &pool); //line:conc:echoservers:initpool
	    while (1) {
		/* Wait for listening/connected descriptor(s) to become ready */
		pool.ready_set = pool.read_set;
		pool.nready = Select(pool.maxfd+1, &pool.ready_set, NULL, NULL, NULL);
	
		/* If listening descriptor ready, add new client to pool */
		if (FD_ISSET(listenfd, &pool.ready_set)) { //line:conc:echoservers:listenfdready
		    connfd = Accept(listenfd, (SA *)&clientaddr, &clientlen); //line:conc:echoservers:accept
		    add_client(connfd, &pool); //line:conc:echoservers:addclient
		}
		
		/* Echo a text line from each ready connected descriptor */ 
		check_clients(&pool); //line:conc:echoservers:checkclients
	    }
	}
	/* $end echoserversmain */
	
	/* $begin init_pool */
	void init_pool(int listenfd, pool *p) 
	{
	    /* Initially, there are no connected descriptors */
	    int i;
	    p->maxi = -1;                   //line:conc:echoservers:beginempty
	    for (i=0; i< FD_SETSIZE; i++)  
		p->clientfd[i] = -1;        //line:conc:echoservers:endempty
	
	    /* Initially, listenfd is only member of select read set */
	    p->maxfd = listenfd;            //line:conc:echoservers:begininit
	    FD_ZERO(&p->read_set);
	    FD_SET(listenfd, &p->read_set); //line:conc:echoservers:endinit
	}
	/* $end init_pool */
	
	/* $begin add_client */
	void add_client(int connfd, pool *p) 
	{
	    int i;
	    p->nready--;
	    for (i = 0; i < FD_SETSIZE; i++)  /* Find an available slot */
		if (p->clientfd[i] < 0) { 
		    /* Add connected descriptor to the pool */
		    p->clientfd[i] = connfd;                 //line:conc:echoservers:beginaddclient
		    Rio_readinitb(&p->clientrio[i], connfd); //line:conc:echoservers:endaddclient
	
		    /* Add the descriptor to descriptor set */
		    FD_SET(connfd, &p->read_set); //line:conc:echoservers:addconnfd
	
		    /* Update max descriptor and pool highwater mark */
		    if (connfd > p->maxfd) //line:conc:echoservers:beginmaxfd
			p->maxfd = connfd; //line:conc:echoservers:endmaxfd
		    if (i > p->maxi)       //line:conc:echoservers:beginmaxi
			p->maxi = i;       //line:conc:echoservers:endmaxi
		    break;
		}
	    if (i == FD_SETSIZE) /* Couldn't find an empty slot */
		app_error("add_client error: Too many clients");
	}
	/* $end add_client */
	
	/* $begin check_clients */
	void check_clients(pool *p) 
	{
	    int i, connfd, n;
	    char buf[MAXLINE]; 
	    rio_t rio;
	
	    for (i = 0; (i <= p->maxi) && (p->nready > 0); i++) {
		connfd = p->clientfd[i];
		rio = p->clientrio[i];
	
		/* If the descriptor is ready, echo a text line from it */
		if ((connfd > 0) && (FD_ISSET(connfd, &p->ready_set))) { 
		    p->nready--;
		    if ((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0) {
			byte_cnt += n; //line:conc:echoservers:beginecho
			printf("Server received %d (%d total) bytes on fd %d\n", 
			       n, byte_cnt, connfd);
			Rio_writen(connfd, buf, n); //line:conc:echoservers:endecho
		    }
	
		    /* EOF detected, remove descriptor from pool */
		    else { 
			Close(connfd); //line:conc:echoservers:closeconnfd
			FD_CLR(connfd, &p->read_set); //line:conc:echoservers:beginremove
			p->clientfd[i] = -1;          //line:conc:echoservers:endremove
		    }
		}
	    }
	}
	/* $end check_clients */

```
例子解析如下，程序首先调用init_poll初始化一个用于记录活动客户端的池(poll)。初始化完池以后，服务器进入一个无限循环。每次循环中，服务器将调用select函数用于检测两个事件，一个是来自一个新客户端的链接请求到大，另一个是已经存在的客户端的已连接描述符准备好可读。如果连接请求到达，服务器将调用add_client()将此客户端的连接描述符加入到poll中。最后，服务器将调用check_client()函数，把来自每个准备好的已连接描述符的一个文本行回送回去。<br />

add_client和check_clients是非常精妙的设计。这构成了一个有限状态模式，select函数用于检测输入事件，add_client函数创建一个新的逻辑流。check_clients函数通过回送输入行来执行状态转移，客户端完成文本行传输时，还需要删除这个状态机。<br />

局限在于，我们在这里能监听到的最大客户端是有限的。编码是较为复杂的。而且需要的代码是基于进程的服务器的3倍，并且，随着并发性粒度的减小，其复杂性还会上升。粒度是指的每个逻辑流每个时间片执行的指令数目。在示例并发服务器中，并发粒度就是读一个完整的文本行所需要的指令数目。如果某个逻辑流忙于读一个文本行，那么其他逻辑流就只能等着。这使得"只发送部分文本行就停止"的攻击方式得以可能。<br />
###基于线程的并发编程
首先写代码:<br />

```c echoservert.c
	/* 
	 * echoservert.c - A concurrent echo server using threads
	 */
	/* $begin echoservertmain */
	#include "csapp.h"
	
	void echo(int connfd);
	void *thread(void *vargp);
	
	int main(int argc, char **argv) 
	{
	    int listenfd, *connfdp, port;
	    socklen_t clientlen=sizeof(struct sockaddr_in);
	    struct sockaddr_in clientaddr;
	    pthread_t tid; 
	
	    if (argc != 2) {
		fprintf(stderr, "usage: %s <port>\n", argv[0]);
		exit(0);
	    }
	    port = atoi(argv[1]);
	
	    listenfd = Open_listenfd(port);
	    while (1) {
		connfdp = Malloc(sizeof(int)); //line:conc:echoservert:beginmalloc
		*connfdp = Accept(listenfd, (SA *) &clientaddr, &clientlen); //line:conc:echoservert:endmalloc
		Pthread_create(&tid, NULL, thread, connfdp);
	    }
	}
	
	/* thread routine */
	void *thread(void *vargp) 
	{  
	    int connfd = *((int *)vargp);
	    Pthread_detach(pthread_self()); //line:conc:echoservert:detach
	    Free(vargp);                    //line:conc:echoservert:free
	    echo(connfd);
	    Close(connfd);
	    return NULL;
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
	
	
	/* $end echoservertmain */

```
这个代码其实和我当初写的DNS Server的代码类似，来一个请求则启动一个线程处理，处理完线程自动退出。因而我们可以看到在thread()函数中实现了对一个连接的完整处理，而主线程只负责监听新的连接请求，来一个请求则建立一个线程，线程创建完毕以后自己detach掉。<br />
这里有一个需要注意的，就是传递给子线程的connfd的值可能会被更改，所以我们用到了malloc()和free()用以保护。<br />
###多线程程序中的共享变量
代码如下：<br />

```c sharing.c
/* $begin sharing */
#include "csapp.h"
#define N 2
void *thread(void *vargp);

char **ptr;  /* global variable */ //line:conc:sharing:ptrdec

int main() 
{
    int i;  
    pthread_t tid;
    char *msgs[N] = {
	"Hello from foo",  
	"Hello from bar"   
    };

    ptr = msgs; 
    for (i = 0; i < N; i++)  
        Pthread_create(&tid, NULL, thread, (void *)i); 
    Pthread_exit(NULL); 
}

void *thread(void *vargp) 
{
    int myid = (int)vargp;
    static int cnt = 0; //line:conc:sharing:cntdec
    printf("[%d]: %s (cnt=%d)\n", myid, ptr[myid], ++cnt); //line:conc:sharing:stack
    return NULL;
}
/* $end sharing */

```
运行结果如下：<br />

```
	[Trusty@XXXyyy chapter12]$ ./sharing 
	[0]: Hello from foo (cnt=1)
	[1]: Hello from bar (cnt=2)

```
这里需要明了的概念是：寄存器是从不共享的，但是虚拟存储器总是共享的。线程1改写了一个存储器位置，那么在线程2中是可以看到这个变化的。<br />
本地静态变量是定义在函数内部并且具备static属性的变量。虚拟存储器的读/写区域里之包含在程序中声明的每个本地静态变量的一个实例，因而在cnt中，运行时由于只有一个cnt的实例，因而每个对等线程都将读/写到这个实例。<br />
###用信号量同步线程
代码如下:<br />

```c badcnt.c
	/* 
	 * badcnt.c - An improperly synchronized counter program 
	 */
	/* $begin badcnt */
	#include "csapp.h"
	
	void *thread(void *vargp);  /* Thread routine prototype */
	
	/* Global shared variable */
	volatile int cnt = 0; /* Counter */
	
	int main(int argc, char **argv) 
	{
	    int niters;
	    pthread_t tid1, tid2;
	
	    /* Check input argument */
	    if (argc != 2) { 
		printf("usage: %s <niters>\n", argv[0]);
		exit(0);
	    }
	    niters = atoi(argv[1]);
	
	    /* Create threads and wait for them to finish */
	    Pthread_create(&tid1, NULL, thread, &niters);
	    Pthread_create(&tid2, NULL, thread, &niters);
	    Pthread_join(tid1, NULL);
	    Pthread_join(tid2, NULL);
	
	    /* Check result */
	    if (cnt != (2 * niters))
		printf("BOOM! cnt=%d\n", cnt);
	    else
		printf("OK cnt=%d\n", cnt);
	    exit(0);
	}
	
	/* Thread routine */
	void *thread(void *vargp) 
	{
	    int i, niters = *((int *)vargp);
	
	    for (i = 0; i < niters; i++) //line:conc:badcnt:beginloop
		cnt++;                   //line:conc:badcnt:endloop
	
	    return NULL;
	}
	/* $end badcnt */

```
如果我们给出一个很大的数，运行将报错，但是如果我们给出的值足够小，那么，没问题，它每次都会运行成功:<br />

```
	[Trusty@XXXyyy chapter12]$ ./badcnt 1000000
	BOOM! cnt=1842364
	[Trusty@XXXyyy chapter12]$ ./badcnt 1000000
	BOOM! cnt=1101701
	[Trusty@XXXyyy chapter12]$ ./badcnt 1000
	OK cnt=2000

```
原因只是在于当数值够大的时候，两个线程的临界区会交替执行。因此计算的最终结果，是小于2cnt。我们可以用信号量来避免这种问题的产生。
###利用信号量访问共享变量
修改过的代码如下：

```c goodcnt1.c
	/* 
	 * badcnt.c - An improperly synchronized counter program 
	 */
	/* $begin badcnt */
	#include "csapp.h"
	
	void *thread(void *vargp);  /* Thread routine prototype */
	
	/* Global shared variable */
	volatile int cnt = 0; /* Counter */
	static sem_t mutex;
	
	int main(int argc, char **argv) 
	{
	    int niters;
	    pthread_t tid1, tid2;
	
	    //sem_t mutex;
	
	    /* Check input argument */
	    if (argc != 2) { 
		printf("usage: %s <niters>\n", argv[0]);
		exit(0);
	    }
	
	    /* Initialize the semaphore */
	    sem_init(&mutex, 0, 1);
	
	    niters = atoi(argv[1]);
	
	    /* Create threads and wait for them to finish */
	    Pthread_create(&tid1, NULL, thread, &niters);
	    Pthread_create(&tid2, NULL, thread, &niters);
	    Pthread_join(tid1, NULL);
	    Pthread_join(tid2, NULL);
	
	    /* Check result */
	    if (cnt != (2 * niters))
		printf("BOOM! cnt=%d\n", cnt);
	    else
		printf("OK cnt=%d\n", cnt);
	    exit(0);
	}
	
	/* Thread routine */
	void *thread(void *vargp) 
	{
	    int i, niters = *((int *)vargp);
	
	    P(&mutex);
	    for (i = 0; i < niters; i++) //line:conc:badcnt:beginloop
	    {
		cnt++;                   //line:conc:badcnt:endloop
	    }
	    V(&mutex);
	
	    return NULL;
	}
	/* $end badcnt */

```
代码的改动只在于加入了mutex的概念，并调用了我们经过封装的P()和V()，这两个函数分别封装了sem_wait()和sem_post(), 	P/V源自于荷兰语，分别代表Proberen(测试)和Verhogen（增加)的意思。<br />
我自己改写的第一版的goodcnt.c中，把P/V加载了for循环中，这将大量增加CPU时间。第二版中在for意外加/减锁。<br />
###基于预线程化的并发服务器
代码如下：<br />

```c echoservert_pre.c
	/* 
	 * echoservert_pre.c - A prethreaded concurrent echo server
	 */
	/* $begin echoservertpremain */
	#include "csapp.h"
	#include "sbuf.h"
	#define NTHREADS  4
	#define SBUFSIZE  16
	
	void echo_cnt(int connfd);
	void *thread(void *vargp);
	
	sbuf_t sbuf; /* shared buffer of connected descriptors */
	
	int main(int argc, char **argv) 
	{
	    int i, listenfd, connfd, port;
	    socklen_t clientlen=sizeof(struct sockaddr_in);
	    struct sockaddr_in clientaddr;
	    pthread_t tid; 
	
	    if (argc != 2) {
		fprintf(stderr, "usage: %s <port>\n", argv[0]);
		exit(0);
	    }
	    port = atoi(argv[1]);
	    sbuf_init(&sbuf, SBUFSIZE); //line:conc:pre:initsbuf
	    listenfd = Open_listenfd(port);
	
	    for (i = 0; i < NTHREADS; i++)  /* Create worker threads */ //line:conc:pre:begincreate
		Pthread_create(&tid, NULL, thread, NULL);               //line:conc:pre:endcreate
	
	    while (1) { 
		connfd = Accept(listenfd, (SA *) &clientaddr, &clientlen);
		sbuf_insert(&sbuf, connfd); /* Insert connfd in buffer */
	    }
	}
	
	void *thread(void *vargp) 
	{  
	    Pthread_detach(pthread_self()); 
	    while (1) { 
		int connfd = sbuf_remove(&sbuf); /* Remove connfd from buffer */ //line:conc:pre:removeconnfd
		echo_cnt(connfd);                /* Service client */
		Close(connfd);
	    }
	}
	/* $end echoservertpremain */

```
这个例子建立了主线程和工作线程。一个主线程用于接受连接并将得到的连接描述符放在一个共享缓冲区中。而每一个工作线程则反复的从共享缓冲区中取出描述符并为客户端服务，然后等待下一个描述符。这种情况适合于短连接。<br />
创建的工作线程创建完毕后其实是detach运行的，然后每个线程将调用sbuf_remove()从sbuf中取出connfd(连接字)，而后调用echo_cnt用于回写行并在终端打印出收到的字节数。<br />
运行结果:<br />

```
	thread -1909590272 received 6 (258 total) bytes on fd 9
	thread -1909590272 received 5 (263 total) bytes on fd 9
	thread -1909590272 received 5 (268 total) bytes on fd 9
	thread -1892804864 received 6 (274 total) bytes on fd 6
	thread -1917982976 received 7 (281 total) bytes on fd 7
	thread -1901197568 received 5 (286 total) bytes on fd 8

```
需要初始化byte_cnt计数器和mutex信号量。pthread_once()函数调用初始化函数在这里是需要注意的。这使得函数包的调用更加容易。
