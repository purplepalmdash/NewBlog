---
layout: post
title: "Programming in C of FC tutorial 2"
date: 2014-04-07 17:43:26 +0800
comments: true
categories: FC
---
###Full Circle C 3
####Exercise 1
Collect all the code snippets on this page and turn them into the working program    
Pointer:     

```c Pointer.c
#include <stdio.h>

int main(void)
{
	int anInt = 5;

	int *anIntPointer = &anInt;

	printf("Address: %p Value: %d \n", &anInt, anInt);

	printf("Address of Pointer: %p Address: %p Value: %d\n", &anIntPointer, anIntPointer, *anIntPointer);

	printf("Size of pointer: %d, size of int: %d\n", sizeof(anIntPointer), sizeof(anInt));

	return 0;
}

```
array.c   

```c array.c
#include <stdio.h>

int main(void)
{
	int i;
	int anIntArray[5] = {10, 20, 30, 40, 50};

	printf("Address of Array: %p \n", &anIntArray);

	printf("Size of Array: %d\n", sizeof(anIntArray));

	for(i = 0; i<sizeof(anIntArray)/sizeof(int); i++)
	{
		printf("Index: %x Address: %p Value: %d, Value: %d\n", i, &anIntArray[i], anIntArray[i], *(anIntArray+i));
	}

	return 0;
}

```

string:    

```c strings.c
#include <stdio.h>
#include <string.h>

int main()
{
	int i;
	char aChar = 'c';
	char * aString = "Hello";

	printf("Address: %p value: %c size: %d\n", &aChar, aChar, sizeof(aChar));

	printf("Address of the string: %p\n", &aString);

	printf("Size of String: %d\n", strlen(aString));

	printf("Value: %s\n", aString);

	for(i = 0; i<=strlen(aString); i++)
	{
		printf("Index:%x Address: %p, Value:%c\n", i, &aString[i], aString[i]);
	}
	return 0;
}

```

Structure:    

```c structure.c
#include <stdio.h>
struct aStruct_def
{
	int intMember;
	int * intPointer;
	char charMember;
	char ** stringPointer;
};

int main(void)
{
	struct aStruct_def aStruct;
	struct aStruct_def *aStructPointer;
	int anInt = 5; 
	char *aString = "Hello";

	printf("Address: %p Size: %d\n", &aStruct, sizeof(struct aStruct_def));

	printf("%p %p %p %p\n", &aStruct.intMember, &aStruct.intPointer, &aStruct.charMember, &aStruct.stringPointer);

	aStruct.intMember = 6;
	aStruct.intPointer = &anInt;
	aStruct.charMember = 'k';
	aStruct.stringPointer = &aString;

	aStructPointer = &aStruct;

	printf("Member of struct: %d\n", (*aStructPointer).intMember);
	printf("Member of struct: %d\n", *(*aStructPointer).intPointer);
	printf("Member of struct: %d\n", aStructPointer->intMember);
	printf("Member of struct: %d\n", *aStructPointer->intPointer);
	printf("Member of struct: %s\n", *aStructPointer->stringPointer);

	return 0;
}

```

####Exercise 2
Implement strlen yourself use a while() loop:    

```c mystrlen.c
#include <stdio.h>

int mystrlen(char *strings)
{
	int i = 0;
	while(strings[i] != '\0')
	{
		i++;
	}
	return i;
}

int main()
{
	char *a = "Hello World";
	printf("%s 's length is %d\n", a, mystrlen(a));
	return 0;
}

```
###Exercise 3
A C application typically has 'int main(int argc, char **argv)' as it's main prototype, here argc contains the number of strings passed to the application, and argc is an array of argc strings. Write a small application which prints all arguments given to the application. What is stored in argv[0] ?    

```c mainargs.c
#include <stdio.h>

int main(int argc, char **argv)
{
	int i = 0; 
	for(i = 0; i<argc; i++)
	{
		printf("arg %d is %s\n", i, argv[i]);
	}
	return 0;
}

```
