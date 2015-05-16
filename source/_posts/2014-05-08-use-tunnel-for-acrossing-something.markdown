---
layout: post
title: "Use Tunnel For Acrossing Something"
date: 2014-05-08 07:53
comments: true
categories: Network
---
### Network Envorinment Introduction
The network envoriment in daily working envoriment is very bad, thus I have to think for a solution, which could improve my network speed.   
Following picture describes the network topology of the daily working.    
![/images/CompanyNetwork1.jpg](/images/CompanyNetwork1.jpg)    

From the picture we can see, several users shared a very narrow path, and this path have to go through chinese firewall, this firewall is ghastly, because it will filter some sensitive website which is not welcomed by CN gov.     
### Our VPN Introduction
There are very wide VPN(Virtual Private Network) between CN and US, the US networking don't have to pass through the firewall.     
Another big surprise is created by the time difference, when chinese are working, lots of american people are out of office.    
![/images/CompanyNetwork2.jpg](/images/CompanyNetwork2.jpg)    

Surely we can make full use of our whole company's network condition.    

### Solution 1: SSH Forwarding
First we will find a server which could forward ssh, just like in the picture.   
![/images/CompanyNetwork3.jpg](/images/CompanyNetwork3.jpg)    

Then we can use following command for setup a ssh tunnel, which could forwarding our network flow to us proxy:    

```
$ ssh -C  -L YourMachine:Port:USProxy:USProxy_Port YouAccount@ForwardingServer

```
Then in your browser or your application, use http://YourMachine:Port as a proxy.     
### Solution 2: TCP Tunnel Forwarding
Not every server can open ssh forwarding for you. For example, in following server, tcp forwarding is forbidden:   

```
$ cat /etc/ssh/sshd_config
# Port forwarding
AllowTcpForwarding no

```
Thus we have to setup our own tcp tunnel manually.     
#### Netcat Way
Use following way you can use netcat for creating a very simple tunnel, which could forwarding all of your flow to US proxy, these operation have to be done on server:     

```
$ mkdir /tmp/fifo
$ nc -lvvp -k 2323 0</tmp/fifo | nc -k USproxy USProxy_Port 1>fifo

```
Then set the local proxy to http://server_ip:2323, then you can reached the proxy.     
#### Tunnel Way
Netcat way is OK, but the netcat version is very old on US Server, it can't support '-k' option, for '-k' option is only supported by openbsd-netcat, and because the server is too old(It's Sun OS 5.10, or solaris? ), so we have to find other ways.     
Luckily I find a small tool, which could fit for our requirement.    

```
$ wget http://www.cri.ensmp.fr/~coelho/tunnel.c
$ gcc -o tunnel tunnel.c -lsocket

```
This compiling will complain 'herror' is not supported, thus we have to comment them, or change them from 'herror' to 'printf', anyway, the error happens seldomly.    
Use following command for setting up a tunnel in server:    

```
$ ./tunnel -Lr server_ip:1080 proxy:80

```
Then in your own PC, set proxy to http://server_ip:1080, you can reach the internet through your own tunnel, which will guide your traffic from VPN to US, then to Internet.    
### Make Tunnel Invisible
Normally system administrator won't like tunnel on server, maybe they will scan the server and find out the port occupation. So we have to do some modification to tunnel.c.   
First, change the name of the executable file: 

```
$ mv tunnel.c autrace.c
$ gcc -o autrace autrace.c -lsocket

```
So now, you can run your tunnel program via './autrace -Lr localhost:1080 proxy:80'.     

But this is not so safe, administrator will also find the port, then they will track this port, and find your tricks, so we have to hidden the port words.   
In autrace.c, do following changes in corresponding lines:    

```
//  Around line 128, change the ip/port into your own. 

/* default connexion. */
#define LHOST "138.138.138.138" /* this really means 127.0.0.1, thus no network! */
#define LPORT "4444"
/* DHOST: <same as chosen LHOST> */
//#define DPORT "23"        /* telnet port */
#define DHOST "139.139.139.139"
#define DPORT "8888"

// Around line 1023, this is actually a bug.  
 dhosts = getenv("DHOST"); 1023

```
Now you can run command like:   

```
$ ./autracce -s

```
### Make Tunnel Only Serve for you
We have to forbidden other user use our tunnel, because http://server_ip:port is open to all of the person in VPN.    
We add following ACL rule in the autrace.c:     

```
// in main(), around line 935
  /* Initialize the parameter for ACL(Access Control List) */
  struct sockaddr_in sa;
  inet_pton(AF_INET, "Your_IP_Address", &(sa.sin_addr));
  allow_address = ntohl(sa.sin_addr.s_addr);

// in main(), around line 1187
      /* In here, we will do filter, filter specified ip address */
      /* Compare the allowed ip address with the incomming's ip address */
      if( allow_address != (ntohl(client_addr.sin_addr.s_addr)))
      {
        fprintf(stderr, "Sorry, you are not welcomed!\n");
        /* No more receive/send any data */
        shutdown(client_socket, 2);
      }

```
The code will check the incoming client's ip address, and comparing it to our pre-defined ip address(Your_IP_Address), if they are not equal, our server will directly close the socket, so the client will receive refuse information.   

Now you have a very safe and reliable path will will let you reach the internet via wide VPN and swift US network, enjoy it. 
