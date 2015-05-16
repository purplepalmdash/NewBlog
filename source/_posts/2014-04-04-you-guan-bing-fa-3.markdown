---
layout: post
title: "有关并发(3)"
date: 2014-04-04 11:06
comments: true
categories: csapp
---
当一个程序的正确性依赖于一个线程需要在另一个线程到达Y点之前到达它控制流中的x点时，就会发生竞争。竞争是因为程序员假定线程按照某种特殊的轨线穿过执行状态空间，而忘了另一条规则规定的，多线程程序必须对任何可行的轨线都正确工作。    
例子如下：    

```c race.c
/* 
 * race.c - demonstrates a race condition
 */
/* $begin race */
#include "csapp.h"
#define N 4

void *thread(void *vargp);

int main() 
{
    pthread_t tid[N];
    int i;

    for (i = 0; i < N; i++) 
	Pthread_create(&tid[i], NULL, thread, &i); //line:conc:race:createthread
    for (i = 0; i < N; i++) 
	Pthread_join(tid[i], NULL);
    exit(0);
}

/* thread routine */
void *thread(void *vargp) 
{
    int myid = *((int *)vargp);  //line:conc:race:derefarg
    printf("Hello from thread %d\n", myid);
    return NULL;
}
/* $end race */

```
运行结果如下:    

```sh 
[Trusty@DashArch chapter12]$ ./race 
Hello from thread 3
Hello from thread 1
Hello from thread 2
Hello from thread 3

```
可以看到程序的执行流并非我们想象的。因而我们可以对程序做改造。改造后的代码如下：    

```c norace.c
/* 
 * norace.c - fixes the race in race.c
 */
/* $begin norace */
#include "csapp.h"
#define N 4

void *thread(void *vargp);

int main() 
{
    pthread_t tid[N];
    int i, *ptr;

    for (i = 0; i < N; i++) {
	ptr = Malloc(sizeof(int));                    //line:conc:norace:createthread1
	*ptr = i;                                     //line:conc:norace:createthread2
	Pthread_create(&tid[i], NULL, thread, ptr);   //line:conc:norace:createthread3
	printf("Now create the %d thread.\n", i);
    } //line:conc:norace:endloop
    for (i = 0; i < N; i++) 
	Pthread_join(tid[i], NULL);
    exit(0);
}

/* thread routine */
void *thread(void *vargp) 
{
    int myid = *((int *)vargp);
    Free(vargp); 
    printf("Hello from thread %d\n", myid);
    return NULL;
}
/* $end norace */

```
运行结果如下：    

```sh
[Trusty@DashArch chapter12]$ ./norace 
Now create the 0 thread.
Hello from thread 0
Hello from thread 1
Now create the 1 thread.
Now create the 2 thread.
Hello from thread 2
Now create the 3 thread.
Hello from thread 3

```
可以看到， 为ID分配独立块，再把指向这个块的指针传递给线程是一个很好的主意。但是注意线程需要释放这些块，以避免存储器泄漏。
