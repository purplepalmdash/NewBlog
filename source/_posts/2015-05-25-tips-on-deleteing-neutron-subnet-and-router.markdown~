---
layout: post
title: "Tips on deleteing neutron subnet and router"
date: 2015-05-25 21:44:54 +0800
comments: true
categories: virtualization
---
Get the existing subnet:     

```
root@Controller:~# neutron subnet-list 
+--------------------------------------+-------------+----------------+--------------------------------------------------+
| id                                   | name        | cidr           | allocation_pools                                 |
+--------------------------------------+-------------+----------------+--------------------------------------------------+
| 98725e3a-7ee2-4e3f-83e3-eaca0236918f | demo-subnet | 192.168.1.0/24 | {"start": "192.168.1.2", "end": "192.168.1.254"} |
+--------------------------------------+-------------+----------------+--------------------------------------------------+
```

Delete it via:     

```
root@Controller:~# neutron subnet-delete --name demo-subnet
Unable to complete operation on subnet 98725e3a-7ee2-4e3f-83e3-eaca0236918f. One or more ports have an IP allocation from this subnet. (HTTP 409) (Request-ID: req-7d729bcc-ec50-4de6-83d9-5d2b98332127)
```

Because we have the router, so we list the router via:    

```
root@Controller:~# neutron router-list
+--------------------------------------+-------------+-----------------------+
| id                                   | name        | external_gateway_info |
+--------------------------------------+-------------+-----------------------+
| a745487e-8e7c-4cc2-aff7-a8423d0a6614 | demo-router | null                  |
+--------------------------------------+-------------+-----------------------+
```

Get the ports of this router:     

```
root@Controller:~# neutron router-port-list a745487e-8e7c-4cc2-aff7-a8423d0a6614
+--------------------------------------+------+-------------------+------------------------------------------------------------------------------------+
| id                                   | name | mac_address       | fixed_ips                                                                          |
+--------------------------------------+------+-------------------+------------------------------------------------------------------------------------+
| e56fe57e-e939-493b-8984-b5adfa64e2cc |      | fa:16:3e:b3:7b:e6 | {"subnet_id": "98725e3a-7ee2-4e3f-83e3-eaca0236918f", "ip_address": "192.168.1.1"} |
+--------------------------------------+------+-------------------+------------------------------------------------------------------------------------+

```

So we remove the interface from this router via:    

```
root@Controller:~# neutron router-interface-delete demo-router 98725e3a-7ee2-4e3f-83e3-eaca0236918f
Removed interface from router demo-router.
root@Controller:~# neutron router-port-list a745487e-8e7c-4cc2-aff7-a8423d0a6614
```

Now we could remove the router and the subnet:     

```
root@Controller:~# neutron router-delete demo-router
Deleted router: demo-router
root@Controller:~# neutron subnet-delete demo-subnet
Deleted subnet: demo-subnet
```

From now on ,you could create another subnet and router.    
