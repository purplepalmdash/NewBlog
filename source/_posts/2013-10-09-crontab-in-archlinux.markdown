---
layout: post
title: "Crontab in ArchLinux"
date: 2013-10-09 10:18
comments: true
categories: Linux
---
1\. Install Crontab in ArchLinux    

```
	$ pacman -S cronie
```

2\. Enable the cronie at startup.    

```
	$ systemctl enable cronie.service
	$ systemctl start cronie.service
	# Display the crontab jobs
	$ crontab -l
```

3\. Edit the crontab jobs:    

```
	MAILTO=your@email
	LOGFILE=/var/log/cron-pacman.log
	
	# 1. minute (0-59)
	# |   2. hour (0-23)
	# |   |   3. day of month (1-31)
	# |   |   |   4. month (1-12)
	# |   |   |   |   5. day of week (0-7: 0 or 7 is Sun, or use names)
	# |   |   |   |   |   6. commandline
	# |   |   |   |   |   |
	#min hr  dom mon dow command
	00   13   *   *   *  . /etc/profile && (echo; date; yes |pacman -Syuq) &>>$LOGFILE || (echo 'pacman failed!'; tail $LOGFILE; false)
	00   13   *   *   *  updatedb && date>>/root/done.txt
```

4\. Now your job will be done automatically.
	

 
