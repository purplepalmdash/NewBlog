---
layout: post
title: "VMware VMCI problem"
date: 2013-11-16 13:57
comments: true
categories: Linux
---
Edit the file /etc/init.d/vmware with your favorite text editor, change the definition:

```
	vmwareLoadModule "$mod"
```

Change this line to 

```
	vmwareLoadModule "$vmci"
```

Then Navigate to the other function  vmwareLoadModule "$mod" Under the function definition.

```
	vmwareLoadModule "$mod"
```

Change this line to 

```
	vmwareLoadModule "$vsock"
```

Now we need to find the corresponding Module Unload functions Under the Function vmwareStopVmci()
Change  

```
	vmwareUnloadModule "${mod}" 
```

to 

```
	vmwareUnloadModule "${vmci}"
```

Under the function vmwareStopVsock() Change

```
	vmwareUnloadModule "$mod"  
```

to 

```
	vmwareUnloadModule "$vsock"
```

Once done I would suggest reboot your machine although not necessary.    
Post that run  sudo /etc/init.d/vmware start     

```
	Starting VMware services:
	   Virtual machine monitor                                             done
	   Virtual machine communication interface                             done
	   VM communication interface socket family                            done
	   Blocking file system                                                done
	   Virtual ethernet                                                    done
	   VMware Authentication Daemon                                        done
	   Shared Memory Available                                             done
```

and now you can see vmware workstation works fine and you are able to power on your virtual machines, and connect to network fine.    
