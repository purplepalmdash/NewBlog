---
layout: post
title: "Programming in C of FC tutorial"
date: 2014-04-07 16:02:08 +0800
comments: true
categories: FC 
---
###Programming In C
GCC's funcitionality:    
gcc command calls a compiler(which transforms a higher level language into assembler), an assembler translates assembler into object files(machine instructions), and a linker, which combines several object files into an executable.     

launchpad.net is a unique collaboration and hosting platform for free software. [http://www.launchpad.net](http://www.launchpad.net).     

###Programming In C II
Example code: 

```c chapter2.c
#include <stdio.h>
#define VERSION "1.0"

/* 
 * Runs a prime check on a given integer, return
 * 1 when the integer is a prime number, 0 otherwise
 */
int isPrime(int prime)
{
	int count = 2;

	// Catch two special cases 
	if(prime == 1)
	{
		return 0;
	}
	else if(prime == 2)
	{
		return 1;
	}
	else
	{
		while(prime % count != 0 && count*count<=prime)
		{
			count++;
		}
		return (prime%count==0)?0:1;
	}
}
/*
 * Print version information
 */
void printVersion()
{
	printf("Primality checker version %s\n", VERSION);
	printf("Compiled on %s %s\n", __DATE__, __TIME__);
}

int main()
{
	int i = 1;
	const int max_prime = 2500;

	printVersion();

	for (i = 1; i<max_prime; i++)
	{
		if(isPrime(i))
		{
			printf("%d is prime\n", i);
		}
		else
		{
			printf("%d is not prime\n", i);
		}
	}
	return 0;
}

```
####Execise 1
Rewrite the for loop in the main() function so it becomes a while loop.     

```c whileloop.c
	//for (i = 1; i<max_prime; i++)
	while(i<max_prime)
	{
		if(isPrime(i))
		{
			printf("%d is prime\n", i);
		}
		else
		{
			printf("%d is not prime\n", i);
		}
		i++;
	}

```
####Execise 2
Rewrite the if...else if...else structure in the isPrime() function to a switch...case structure.    

```c switchcase.c
	int count = 2;
	int returnvalue = 0;

	// Catch two special cases 
	switch(prime)
	{
		case 1:
			returnvalue = 0;
			break;
		case 2:
			returnvalue = 1;
			break;
		default:
			while(prime % count != 0 && count*count <= prime)
			{
				count++;
			}
			returnvalue =  (prime % count == 0)?0:1;

	}
	return returnvalue;

```
####Execise 3
Rewrite the ternary(condition)?value1:value2 to an if..else structure    

```c ifelse.c
//return (prime%count==0)?0:1;
if(prime%count == 0)
{
	return 0;
}
else
{
	return 1;
}

```
####Execise 4
Rewrite the if...else in the main() funciton to make sure the ternary operator    

```c ternary.c
/*
if(isPrime(i))
{
	printf("%d is prime\n", i);
}
else
{
	printf("%d is not prime\n", i);
}
*/
printf("%d %s prime\n", i, isPrime(i)?"is":"is not");

```
####Execise 5
Replace the isPrime() function by an isOdd() function which return 1 when a given integer is odd.    

```c isOdd.c
int isOdd(int odd)
{
	if(odd == 1)
	{
		return 1;
	}
	else
	{
		if(odd%2 == 0)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
}

/* Called via */
if(isOdd(i))
{
	printf("%d is Odd\n", i);
}
else
{
	printf("%d is not Odd\n", i);
}

```
####Execise 6
Design and write a small application which print out the n Fibonacci sequence, where n should be easily modifiable.    

```c fib.c
#include <stdio.h>

/* The formula is like
 * a(n+2) = a(n)+a(n+1)
 * while when a1 = 1, a2 =1
 */

int Fib(int fib)
{
	if(fib == 1)
	{
		return 1;
	}
	else if(fib == 2)
	{
		return 1;
	}
	else
	{
		return (Fib(fib-1) + Fib(fib-2));
	}
}

int main(int argc, char **argv)
{
	int i;
	int j = 1;

	printf("Please input an integer number\n");
	scanf("%d", &i);

	printf("The Fibonacci sequence is: \n");
	for( j = 1; j <= i; j++)
	{
		printf("a[%d] is %d.\n", j, Fib(j));
	}

	return 0;
}

```
Because we use recursion here, when the n is too big, the calculation maybe very slow. 
