---
layout: post
title: "Insert public key into Cobbler Deployed System"
date: 2015-06-29 14:13:08 +0800
comments: true
categories: Virtualization
---
First edit your kickstart file, add following line before the end of your kickstart:      

```
[root@z_WHServer kickstarts]# pwd
/var/lib/cobbler/kickstarts
[root@z_WHServer kickstarts]# cat sample_end.ks
# Start final steps
+ $SNIPPET('publickey_root')
$SNIPPET('kickstart_done')
# End final steps
%end
```

And the `publickey_root ` should be edited as following:    

```
[root@z_WHServer snippets]# pwd
/var/lib/cobbler/snippets
[root@z_WHServer snippets]# cat publickey_root
# Install CobblerServer's(10.47.58.2) public key for root user
cd /root
mkdir --mode=700 .ssh
cat >> .ssh/authorized_keys << "PUBLIC_KEY"
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3B3GtGuKY0l2Ak9+WSkorY7R+Cx5/u3RMua/7GrvP05IPywQdkR+mqwdRydNjyhB96nHlYZtr8Fbfn5iwqn0j8dz8wmTZicBNeRqIdbe/YUje5NjXxDXjYda63VfDhpgzJ53KICTx6pBhGaeOKS/U5HqCpDbF7ODP8siU7bRhk1LkIQ6VwZYUg7b0oR+Sw6XJ31Z7gs4CWF6zfjfQQoF7EoMA+dnqvt2K4PQPXNSBJQx3qb9jyXIXvo333PcfIX6mD1TW1wDAIXLm4qz4mi7C8Ax9h+T/D98r08WX360vC5Tzr8feXMs6H4il4s4Ftq7RVoqCNKmG3AB1LTp4AQAzw== root@z_WHServer
PUBLIC_KEY
chmod 600 .ssh/authorized_keys
cat >> .ssh/config <<EOF
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
EOF
```
Better you run `cobber sync` after updating your kickstart file.     
