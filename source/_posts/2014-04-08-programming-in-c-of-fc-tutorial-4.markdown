---
layout: post
title: "Programming in C of FC tutorial 4"
date: 2014-04-08 16:01:06 +0800
comments: true
categories: FC
---
###Full Circle C 6
####Using valgrid for memory check
See [www.valgrind.org](www.valgrind.org) for more information for using the valgrind available tools.     
memcheck is the main topic in this chapter.     
this tool override libc calls that deal with handling memory. And it will do some bookkeeping. is all memory given back to the system, and is all the allocated memory still reachable?     

```c leak.c
#include <stdio.h>
#include <stdlib.h>

void leak()
{
        char *ptr = malloc(10);
        printf("malloc(10) points to: %p\n", ptr);
}

int main()
{
        int i = 0;
        for(i = 0; i<10; i++)
        {
                leak();
        }
        char *ptr = malloc(15);
        printf("malloc(15) in main: %p\n", ptr);
        while(1){}
        return 0;
}

```
The result shows:     

```sh
valgrind --leak-check=full --show-reachable=yes ./memleak
==2144== Memcheck, a memory error detector.
==2144== Copyright (C) 2002-2006, and GNU GPL'd, by Julian Seward et al.
==2144== Using LibVEX rev 1658, a library for dynamic binary translation.
==2144== Copyright (C) 2004-2006, and GNU GPL'd, by OpenWorks LLP.
==2144== Using valgrind-3.2.1, a dynamic binary instrumentation framework.
==2144== Copyright (C) 2000-2006, and GNU GPL'd, by Julian Seward et al.
==2144== For more details, rerun with: -v
==2144==
malloc(10) points to: 0x4022028
malloc(10) points to: 0x4022068
malloc(10) points to: 0x40220a8
malloc(10) points to: 0x40220e8
malloc(10) points to: 0x4022128
malloc(10) points to: 0x4022168
malloc(10) points to: 0x40221a8
malloc(10) points to: 0x40221e8
malloc(10) points to: 0x4022228
malloc(10) points to: 0x4022268
malloc(15) in main: 0x40222a8
==2144==
==2144== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 12 from 1)
==2144== malloc/free: in use at exit: 115 bytes in 11 blocks.
==2144== malloc/free: 11 allocs, 0 frees, 115 bytes allocated.
==2144== For counts of detected errors, rerun with: -v
==2144== searching for pointers to 11 not-freed blocks.
==2144== checked 46,792 bytes.
==2144==
==2144== 15 bytes in 1 blocks are still reachable in loss record 1 of 2
==2144==    at 0x40053C0: malloc (vg_replace_malloc.c:149)
==2144==    by 0x8048419: main (leak.c:17)
==2144==
==2144==
==2144== 100 bytes in 10 blocks are definitely lost in loss record 2 of 2
==2144==    at 0x40053C0: malloc (vg_replace_malloc.c:149)
==2144==    by 0x80483C5: leak (leak.c:6)
==2144==    by 0x8048403: main (leak.c:15)
==2144==
==2144== LEAK SUMMARY:
==2144==    definitely lost: 100 bytes in 10 blocks.
==2144==      possibly lost: 0 bytes in 0 blocks.
==2144==    still reachable: 15 bytes in 1 blocks.
==2144==         suppressed: 0 bytes in 0 blocks.

```
If we change the code into following, this means valgrid won't interpret the output, so this will let the tracked memory add 10    

```c leak1.c
#include <stdio.h>
#include <stdlib.h>

void leak()
{
        char *ptr = malloc(10);
        printf("malloc(10) points to: %p\n", ptr);
}

int main()
{
        int i = 0;
        for(i = 0; i<10; i++)
        {
                leak();
        }
        char *ptr = malloc(15);
        printf("malloc(15) in main: %p\n", ptr);
        //while(1){}
        return 0;
}

```

Compile and verify:    

```sh 
gcc -Wall -g leak1.c -o memleak1
View the valgrind result:
valgrind --leak-check=full --show-reachable=yes ./memleak1
==2190== Memcheck, a memory error detector.
==2190== Copyright (C) 2002-2006, and GNU GPL'd, by Julian Seward et al.
==2190== Using LibVEX rev 1658, a library for dynamic binary translation.
==2190== Copyright (C) 2004-2006, and GNU GPL'd, by OpenWorks LLP.
==2190== Using valgrind-3.2.1, a dynamic binary instrumentation framework.
==2190== Copyright (C) 2000-2006, and GNU GPL'd, by Julian Seward et al.
==2190== For more details, rerun with: -v
==2190==
malloc(10) points to: 0x4022028
malloc(10) points to: 0x4022068
malloc(10) points to: 0x40220a8
malloc(10) points to: 0x40220e8
malloc(10) points to: 0x4022128
malloc(10) points to: 0x4022168
malloc(10) points to: 0x40221a8
malloc(10) points to: 0x40221e8
malloc(10) points to: 0x4022228
malloc(10) points to: 0x4022268
malloc(15) in main: 0x40222a8
==2190==
==2190== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 12 from 1)
==2190== malloc/free: in use at exit: 115 bytes in 11 blocks.
==2190== malloc/free: 11 allocs, 0 frees, 115 bytes allocated.
==2190== For counts of detected errors, rerun with: -v
==2190== searching for pointers to 11 not-freed blocks.
==2190== checked 46,796 bytes.
==2190==
==2190== 15 bytes in 1 blocks are definitely lost in loss record 1 of 2
==2190==    at 0x40053C0: malloc (vg_replace_malloc.c:149)
==2190==    by 0x8048419: main (leak1.c:17)
==2190==
==2190==
==2190== 100 bytes in 10 blocks are definitely lost in loss record 2 of 2
==2190==    at 0x40053C0: malloc (vg_replace_malloc.c:149)
==2190==    by 0x80483C5: leak (leak1.c:6)
==2190==    by 0x8048403: main (leak1.c:15)
==2190==
==2190== LEAK SUMMARY:
==2190==    definitely lost: 115 bytes in 11 blocks.
==2190==      possibly lost: 0 bytes in 0 blocks.
==2190==    still reachable: 0 bytes in 0 blocks.
==2190==         suppressed: 0 bytes in 0 blocks.

```
####exercise 1:
vmstat is a tool which report system usage statistics, use strace to figure out which /proc/file(s) it uses to generate its output   

```sh 
execve("/usr/bin/vmstat", ["vmstat"], [/* 29 vars */]) = 0
brk(0)                                  = 0x96b7000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=95416, ...}) = 0
mmap2(NULL, 95416, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7f80000
close(3)                                = 0
open("/lib/libproc-3.2.7.so", O_RDONLY) = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320c\304\0004\0\0\0"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=54212, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f7f000
mmap2(0xc44000, 133592, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xc44000
mmap2(0xc51000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xc) = 0xc51000
mmap2(0xc52000, 76248, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xc52000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320?\261\0004\0\0\0"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=1606808, ...}) = 0
mmap2(0xafe000, 1324452, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xafe000
mmap2(0xc3c000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13e) = 0xc3c000
mmap2(0xc3f000, 9636, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xc3f000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f7e000
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7f7e6c0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
mprotect(0xc3c000, 8192, PROT_READ)     = 0
mprotect(0xaf5000, 4096, PROT_READ)     = 0
munmap(0xb7f80000, 95416)               = 0
uname({sys="Linux", node="localhost.localdomain", ...}) = 0
brk(0)                                  = 0x96b7000
brk(0x96d8000)                          = 0x96d8000
open("/proc/stat", O_RDONLY)            = 3
fstat64(3, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f97000
read(3, "cpu  14886 15300 97152 608490 41"..., 4096) = 693
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0xb7f97000, 4096)                = 0
ioctl(1, TIOCGWINSZ, {ws_row=36, ws_col=115, ws_xpixel=0, ws_ypixel=0}) = 0
fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 4), ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f97000
write(1, "procs -----------memory---------"..., 82procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
) = 82
write(1, " r  b   swpd   free   buff  cach"..., 81 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
) = 81
open("/proc/meminfo", O_RDONLY)         = 3
lseek(3, 0, SEEK_SET)                   = 0
read(3, "MemTotal:       897068 kB\nMemFre"..., 1023) = 771
open("/proc/stat", O_RDONLY)            = 4
read(4, "cpu  14886 15300 97153 608490 41"..., 65535) = 693
open("/proc/vmstat", O_RDONLY)          = 5
lseek(5, 0, SEEK_SET)                   = 0
read(5, "nr_anon_pages 29682\nnr_mapped 13"..., 1023) = 803
write(1, " 0  0    120  16980  32852 67407"..., 81 0  0    120  16980  32852 674076    0    0   228   223 1040  432  4 13 78  5  0
) = 81
exit_group(0)                           = ?

```
From the above output, we can see, it access /proc/stat and /proc/vmstat for output message.    
####exercise 2
Repeat the ltrace /strace example on wget with ivalid URL, TBD    
####exercise 3
Does valgrind automatically trace child process?      

```c fork.c
#include <stdio.h>
#include <stdlib.h>

/* For using fork() */
#include <sys/types.h>
#include <unistd.h>

/* Using errono */
#include <errno.h>
#include <string.h>


void leak()
{
        char *ptr = malloc(10);
        printf("malloc(10) points to: %p\n", ptr);
}

int main(void)
{
        pid_t child;
        /* Parent do leak() */
        int i = 0;
        for(i = 0; i<10; i++)
        {
                leak();
        }

        /* Now fork a child process */
        if((child = fork()) < 0) {
                fprintf(stderr, "fork of child failed: %s\n", strerror(errno));
                return 1;
        }
        else if(child == 0) {
                printf("Now its in child process\n");
                sleep(2);
        }
        else {
                // parent will exit immediately !
                printf("Parent will exit!\n");
                sleep(1);
                return 0;
        }

        // Only Child comes here
        printf("Only child comes here!\n");
        for(i = 0; i<10; i++)
        {
                leak();
        }

        return 0;
}

```
We use following command for tracing the output:     

```sh 
[root@localhost code]# valgrind --leak-check=full --show-reachable=yes ./memleak_fork
==2561== Memcheck, a memory error detector.
==2561== Copyright (C) 2002-2006, and GNU GPL'd, by Julian Seward et al.
==2561== Using LibVEX rev 1658, a library for dynamic binary translation.
==2561== Copyright (C) 2004-2006, and GNU GPL'd, by OpenWorks LLP.
==2561== Using valgrind-3.2.1, a dynamic binary instrumentation framework.
==2561== Copyright (C) 2000-2006, and GNU GPL'd, by Julian Seward et al.
==2561== For more details, rerun with: -v
==2561==
malloc(10) points to: 0x4022028
malloc(10) points to: 0x4022068
malloc(10) points to: 0x40220a8
malloc(10) points to: 0x40220e8
malloc(10) points to: 0x4022128
malloc(10) points to: 0x4022168
malloc(10) points to: 0x40221a8
malloc(10) points to: 0x40221e8
malloc(10) points to: 0x4022228
malloc(10) points to: 0x4022268
Now its in child process
Parent will exit!
==2561==
==2561== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 12 from 1)
==2561== malloc/free: in use at exit: 100 bytes in 10 blocks.
==2561== malloc/free: 10 allocs, 0 frees, 100 bytes allocated.
==2561== For counts of detected errors, rerun with: -v
==2561== searching for pointers to 10 not-freed blocks.
==2561== checked 46,796 bytes.
==2561==
==2561== 100 bytes in 10 blocks are definitely lost in loss record 1 of 1
==2561==    at 0x40053C0: malloc (vg_replace_malloc.c:149)
==2561==    by 0x8048515: leak (fork.c:15)
==2561==    by 0x8048553: main (fork.c:26)
==2561==
==2561== LEAK SUMMARY:
==2561==    definitely lost: 100 bytes in 10 blocks.
==2561==      possibly lost: 0 bytes in 0 blocks.
==2561==    still reachable: 0 bytes in 0 blocks.
==2561==         suppressed: 0 bytes in 0 blocks.
[root@localhost code]# Only child comes here!
malloc(10) points to: 0x40222a8
malloc(10) points to: 0x40222e8
malloc(10) points to: 0x4022328
malloc(10) points to: 0x4022368
malloc(10) points to: 0x40223a8
malloc(10) points to: 0x40223e8
malloc(10) points to: 0x4022428
malloc(10) points to: 0x4022468
malloc(10) points to: 0x40224a8
malloc(10) points to: 0x40224e8
==2562==
==2562== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 12 from 1)
==2562== malloc/free: in use at exit: 200 bytes in 20 blocks.
==2562== malloc/free: 20 allocs, 0 frees, 200 bytes allocated.
==2562== For counts of detected errors, rerun with: -v
==2562== searching for pointers to 20 not-freed blocks.
==2562== checked 46,796 bytes.
==2562==
==2562== 200 bytes in 20 blocks are definitely lost in loss record 1 of 1
==2562==    at 0x40053C0: malloc (vg_replace_malloc.c:149)
==2562==    by 0x8048515: leak (fork.c:15)
==2562==    by 0x8048553: main (fork.c:26)
==2562==
==2562== LEAK SUMMARY:
==2562==    definitely lost: 200 bytes in 20 blocks.
==2562==      possibly lost: 0 bytes in 0 blocks.
==2562==    still reachable: 0 bytes in 0 blocks.
==2562==         suppressed: 0 bytes in 0 blocks.

```
From the above output, we can see valgrid also tracked the child process's memory usage. 
