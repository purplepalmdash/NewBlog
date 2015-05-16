---
layout: post
title: "Programming in C of FC tutorial 3"
date: 2014-04-08 09:41:55 +0800
comments: true
categories: FC
---
###Full Circle C 5
####Callback
Use Call Back function for implementing a calculator:    

```c CB_Calculator.c
#include <stdio.h>

int minus(int a, int b)
{
	return a-b;
}

int add(int a, int b)
{
	return a+b;
}

int multiply(int a, int b)
{
	return a*b;
}

int divide(int a, int b)
{
	return a/b;
}

typedef int (*mathFun)(int, int);

struct operator
{
	char c;
	mathFun f;
};

int main()
{
	struct operator functs[4];
	functs[0].c = '-'; functs[0].f=&minus;
	functs[1].c = '+'; functs[1].f=&add;
	functs[2].c = '*'; functs[2].f=&multiply;
	functs[3].c = '/'; functs[3].f=&divide;
	while(1)
	{
		int a,b,i;
		char c;
		printf("Enter a:\n");
		scanf("%d", &a);
		printf("Enter b:\n");
		scanf("%d", &b);
		printf("Enter the operator:\n");
		scanf("%c", &c);
		scanf("%c", &c);
		i = 0;
		while(i<4)
		{
			if(functs[i].c==c)
			{
				printf("Result:%d\n", functs[i].f(a,b));
				break;
			}
			i++;
		}
		if(i == 4)
		{
			printf("Unkown operator:%c\n", c);
		}
	}
	return 0;
}

```
####Exercise 1
Modify the application to operate on floating point numbers instead of integers.    

```c cal_float.c
#include <stdio.h>

float  minus(float a, float b)
{
	return a-b;
}

float add(float a, float b)
{
	return a+b;
}

float multiply(float a, float b)
{
	return a*b;
}

float divide(float a, float b)
{
	return a/b;
}

typedef float (*mathFun)(float, float);

struct operator
{
	char c;
	mathFun f;
};

int main()
{
	struct operator functs[4];
	functs[0].c = '-'; functs[0].f=&minus;
	functs[1].c = '+'; functs[1].f=&add;
	functs[2].c = '*'; functs[2].f=&multiply;
	functs[3].c = '/'; functs[3].f=&divide;
	while(1)
	{
		int i;
		float a,b; 
		char c;
		printf("Enter a:\n");
		scanf("%f", &a);
		printf("Enter b:\n");
		scanf("%f", &b);
		printf("Enter the operator:\n");
		scanf("%c", &c);
		scanf("%c", &c);
		i = 0;
		while(i<4)
		{
			if(functs[i].c==c)
			{
				printf("Result:%f\n", functs[i].f(a,b));
				break;
			}
			i++;
		}
		if(i == 4)
		{
			printf("Unkown operator:%c\n", c);
		}
	}
	return 0;
}

```
####Exercise 2
Extend the calculator with the possibility for the user to enter 'q' for quit    

```c qforquit.c
#include <stdio.h>

int minus(int a, int b)
{
	return a-b;
}

int add(int a, int b)
{
	return a+b;
}

int multiply(int a, int b)
{
	return a*b;
}

int divide(int a, int b)
{
	return a/b;
}

typedef int (*mathFun)(int, int);

struct operator
{
	char c;
	mathFun f;
};

int main()
{
	struct operator functs[4];
	functs[0].c = '-'; functs[0].f=&minus;
	functs[1].c = '+'; functs[1].f=&add;
	functs[2].c = '*'; functs[2].f=&multiply;
	functs[3].c = '/'; functs[3].f=&divide;
	char q;
	do
	{
		int a,b,i;
		char c;
		printf("Enter a:\n");
		scanf("%d", &a);
		printf("Enter b:\n");
		scanf("%d", &b);
		printf("Enter the operator:\n");
		scanf("%c", &c);
		scanf("%c", &c);
		i = 0;
		while(i<4)
		{
			if(functs[i].c==c)
			{
				printf("Result:%d\n", functs[i].f(a,b));
				break;
			}
			i++;
		}
		if(i == 4)
		{
			printf("Unkown operator:%c\n", c);
		}
		printf("Enter q for quit! Others for continue\n");
		scanf("%c",&q);
		scanf("%c",&q);
	}
	while(q != 'q');
	return 0;
}

```
####Exercise 4
Modify the application that, instead of entering characters, the user is able to enter “5 plus 6” or “6 minus 5”. In order to do this, you will need to adapt the structure to hold a string as the operator, and, instead of reading a character, you will need to read a string. Extra credit if you manage to do this without buffer overrun issues (see man getline) and memory leaks.    

```c human.c
#include <stdio.h>
#include <string.h>

int minus(int a, int b)
{
	return a-b;
}

int add(int a, int b)
{
	return a+b;
}

int multiply(int a, int b)
{
	return a*b;
}

int divide(int a, int b)
{
	return a/b;
}

typedef int (*mathFun)(int, int);

struct operator
{	char c[20];
	mathFun f;
};

int main()
{
	struct operator functs[4];
	strcpy(functs[0].c, "minus");
	functs[0].f=&minus;
	strcpy(functs[1].c, "add");
	functs[1].f=&add;
	strcpy(functs[2].c, "mul");
	functs[2].f=&multiply;
	strcpy(functs[3].c, "div");
	functs[3].f=&divide;
	while(1)
	{
		int a,b,i;
		char c[20];
		printf("Enter a:\n");
		scanf("%d", &a);
		printf("Enter b:\n");
		scanf("%d", &b);
		printf("Enter the operator:\n");
		scanf("%s", c);
		i = 0;
		while(i<4)
		{
			int result = strcmp(functs[i].c, c);
			if(result == 0)
			{
			printf("Result is :%d\n", functs[i].f(a,b));
			break;
			}
			i++;
		}
		if(i == 4)
		{
			printf("Unkown operator:%s\n", c);
		}
	}
	return 0;
}

```
