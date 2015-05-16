---
layout: post
title: "Programming in C of FC tutorial 6"
date: 2014-04-08 16:50:56 +0800
comments: true
categories: FC
---
###Full Circle C 8
####Limitation
Fibonacci sequence: normally this program limited by the limitation of unsigned long long 

```c Fibonacci.c
#include <stdio.h>

typedef unsigned long long fibo_type;
#define FIBO_FORMAT "%10llu"

void printFibo(fibo_type num)
{
        printf(FIBO_FORMAT, num);
}

int main()
{
        int num = 0;
        fibo_type a = 0, b=1, c;

        printf("%4d: ", ++num);
        printFibo(a);
        printf("\n");

        printf("%4d: ",++num);
        printFibo(b);
        printf("\n");

        c=a+b;
        while(c>=b)
        {
                printf("%4d: ",++num);
                printFibo(c);
                printf("\n");
                a=b;
                b=c;
                c=a+b;
        }

        printf("Stopped after %d digits\n", num);
        printFibo(c);
        printf("\n");
        return 0;
}

```
This program will exit when c reach the limitation of definition of unsigned long long
####Using GMP
Using gmp to re-write this program:

```c Fibonacci2.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gmp.h>

int main()
{
        int num = 0;
        mpz_t f_1;
        mpz_t f_2;

        mpz_init(f_1);
        mpz_init(f_2);
        mpz_set_ui(f_1, 0);
        mpz_set_ui(f_1, 1);
        printf("%10d: 0\n", ++num);

        while(1)
        {
                mpz_add(f_1, f_2, f_1);
                mpz_swap(f_1, f_2);
                char *res = mpz_get_str(NULL, 10, f_2);
                printf("%10d: %s\n", ++num, res);
                free(res);
                sleep(1);
        }

        mpz_clear(f_1);
        mpz_clear(f_2);
        return 0;
}

```
Compile it via:    

```sh run.sh
gcc -o Fibonacci2 Fibonacci2.c -lgmp

```
This won't have limitation currently, but you have to finish the execises, when you get internet connection. 
