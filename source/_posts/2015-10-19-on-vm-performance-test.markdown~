---
layout: post
title: "On VM Performance Test"
date: 2015-10-19 09:54:45 +0800
comments: true
categories: Virtualization
---
### AIM
To build the testing Framework.   

### Reference Material
[Paper_16-Performance_Evaluation_of_Private_Clouds.pdf](http://thesai.org/Downloads/Volume5No5/Paper_16-Performance_Evaluation_of_Private_Clouds.pdf)   

[http://www.junauza.com/2012/05/best-system-benchmarking-tools-for.html](http://www.junauza.com/2012/05/best-system-benchmarking-tools-for.html)   

### Software
Install following software:    

```

# apt-get install -y  libx11-dev libgl1-mesa-dev libxext-dev perl perl-modules make gcc nfs-common
postgresql-9.1 postgresql-contrib-9.1 mbw iperf
```


### CPU
The following software are introduced for testing CPU Performance:
* Linpack
* Lookbusy

#### Linpack
Note: Only works on INTEL CPU.    

[Linux](http://registrationcenter-download.intel.com/akdlm/irc_nas/2169/l_lpk_p_10.3.4.007.tgz)

[Windows](http://registrationcenter-download.intel.com/akdlm/irc_nas/2169/w_lpk_p_10.3.4.007.zip)    

[Mac](http://registrationcenter-download.intel.com/akdlm/irc_nas/2169/m_lpk_p_10.3.4.007.tgz)    

Linux Steps:    

```
$ tar xvf l_lpk_p_10.3.4.007.tgz
$ cd linpack_10.3.4/benchmarks/linpack
$ ./runme_xeon64
```

You can see the testing result via `tail -f lin_xeon64.txt`.     

Note your CPU's temperature and your system load are changing.    

#### Lookbusy
[https://www.devin.com/lookbusy/](https://www.devin.com/lookbusy/)    
Download and install it via:    

```
# wget https://www.devin.com/lookbusy/download/lookbusy-1.4.tar.gz
# tar xzvf lookbusy-1.4.tar.gz
# cd lookbusy-1.4/
# ./configure --prefix=/usr
# make && make install
# lookbusy
```
Default will add 50% load to each CPU.   

####  

### Memory
#### Stream
[https://www.cs.virginia.edu/stream/ref.html](https://www.cs.virginia.edu/stream/ref.html)   

Get the source code from:
[https://www.cs.virginia.edu/stream/FTP/Code/](https://www.cs.virginia.edu/stream/FTP/Code/)    

Then compile it and run:    

```
# make stream_c.exe
# ./stream_c.exe
```

### Disk IO
#### Bonnie++
[测试工具Bonnie++的使用](http://blog.csdn.net/choice_jj/article/details/8026130)    

### Network IO
#### Iperf
To be added.   

### OverAll
System Level Testing Framework.   
#### UnixBench
Download the source file, then run it, and see the result.   

```
# wget http://byte-unixbench.googlecode.com/files/UnixBench5.1.3.tgz
# tar xvf UnixBench5.1.3.tgz
# cd UnixBench
# make
# ./Run 2>&1 | tee RunResult.txt
```
#### LMBench
[http://www.bitmover.com/lmbench/](http://www.bitmover.com/lmbench/)  

[LM Usage](http://blog.csdn.net/dianhuiren/article/details/7331777)   

 
