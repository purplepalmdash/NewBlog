---
layout: post
title: "Manually delete spam comments for WP"
date: 2014-11-06 12:21
comments: true
categories: linux
---
Login to mysql commandline via:    

```
# mysql -uroot -p
mysql> use wordpress
.........
Database changed

```

Display the COLUMNS of wp_comments:    

```
mysql> SHOW COLUMNS FROM wp_comments;
+----------------------+---------------------+------+-----+---------------------+----------------+
| Field                | Type                | Null | Key | Default             | Extra          |
+----------------------+---------------------+------+-----+---------------------+----------------+
| comment_ID           | bigint(20) unsigned | NO   | PRI | NULL                | auto_increment |
| comment_post_ID      | bigint(20) unsigned | NO   | MUL | 0                   |                |
| comment_author       | tinytext            | NO   |     | NULL                |                |
| comment_author_email | varchar(100)        | NO   | MUL |                     |                |
| comment_author_url   | varchar(200)        | NO   |     |                     |                |
| comment_author_IP    | varchar(100)        | NO   |     |                     |                |
| comment_date         | datetime            | NO   |     | 0000-00-00 00:00:00 |                |
| comment_date_gmt     | datetime            | NO   | MUL | 0000-00-00 00:00:00 |                |
| comment_content      | text                | NO   |     | NULL                |                |
| comment_karma        | int(11)             | NO   |     | 0                   |                |
| comment_approved     | varchar(20)         | NO   | MUL | 1                   |                |
| comment_agent        | varchar(255)        | NO   |     |                     |                |
| comment_type         | varchar(20)         | NO   |     |                     |                |
| comment_parent       | bigint(20) unsigned | NO   | MUL | 0                   |                |
| user_id              | bigint(20) unsigned | NO   |     | 0                   |                |
| comment_mail_notify  | tinyint(4)          | NO   |     | 0                   |                |
+----------------------+---------------------+------+-----+---------------------+----------------+
16 rows in set (0.00 sec)

```
If you want to display the last 30 minutes' comments:    

```
mysql> SELECT * FROM wp_comments WHERE comment_date  BETWEEN TIMESTAMPADD(MINUTE, -30, NOW()) AND NOW();

```
Delete last 30 minutes' comments:    

```
mysql> DELETE FROM wp_comments WHERE comment_date  BETWEEN TIMESTAMPADD(MINUTE, -30, NOW()) AND NOW();
Query OK, 536 rows affected (0.18 sec)

```

Select and Delete 10 day's comments:    

```
mysql> select * from wp_comments where datediff(now(), comment_date)<10;
mysql> delete from wp_comments where datediff(now(), comment_date)<10;
Query OK, 31029 rows affected (1.34 sec)

```

Disable postfix on startup:     

```
# update-rc.d postfix disable

```
