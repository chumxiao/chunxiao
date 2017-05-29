linux的mysql远程授权：
grant all privileges on *.* to 'root'@'172.25.254.175' identified by '123456' with grant option;
flush privileges
在172.25.254.175上登陆：
(前期：172.25.254.174的防火墙处于关闭状态)
mysql -uroot -p123456 -h 172.25.254.174
自动备份工具Xtrabackup
官网下载tar包（www.percona.com）
1.完全备份：
[root@desktop7 ~]#  vim /etc/my.cnf

定位且添加：

thread_concurrency  = 4

datadir =  /data/mydata

innodb_file_per_table  = ON

指定自定义路径：

log-bin=/data/binlogs/mysql-bin
2.停止mysql
/etc/init.d/mysql stop
3.创建binlogs目录：
root@localhost ~]#  mkdir /data/binlogs/

[root@desktop7 ~]#  chown -R mysql:mysql /data/binlogs/
4.启动mysql
5.进入mysql查看日志：
MariaDB  [(none)]> SHOW BINARY LOGS;

+-------------------+-----------+

| Log_name          | File_size |

+-------------------+-----------+

| mysql-bin.000001  |       870 |

+-------------------+-----------+
6.删除/data/mydata/目录下的mysql-bin.*日志文件
[root@desktop7 mydata]# ls
aria_log.00000001         ibdata1            performance_schema
aria_log_control          ib_logfile0        xiaoma
desktop7.example.com.err  ib_logfile1        xtrabackup_binlog_pos_innodb
desktop7.example.com.pid  multi-master.info  xtrabackup_info
hcx1                      mysql
7 创建备份所需目录：
mkdir /mybackups
8.查看都是InnoDB的引擎：
ysql> show table status from hcx1\G;
*************************** 1. row ***************************
           Name: hehe
         Engine: InnoDB
        Version: 10
9.完全备份（注意：备份时候MySQL必须是运行状态，而在做数据恢复时候服务必须处于停滞状态。）
[root@desktop7 ~]#  innobackupex --user=root -p123456 /mybackups/

省略...出现此行可以了。

140307  09:43:00  innobackupex: completed OK!
10.查看备份后的数据：
[root@desktop7 mydata]# cd /mybackups/
[root@desktop7 mybackups]# ls
2017-05-29_11-39-14
[root@desktop7 mybackups]# cd 2017-05-29_11-39-14/
[root@desktop7 2017-05-29_11-39-14]# ls
backup-my.cnf  ibtmp1                  xtrabackup_binlog_pos_innodb
hcx1           mysql                   xtrabackup_checkpoints
ibdata1        performance_schema      xtrabackup_info
ib_logfile0    xiaoma                  xtrabackup_logfile
ib_logfile1    xtrabackup_binlog_info
11.做一个完全备份还原恢复：
模拟停止服务及删除/data/mydata目录下的所有数据：(备份前后没有做任何操作)
1.停止mysql, rm -fr /data/mydata/*
12.先准备一个完全备份：
[root@desktop7 binlogs]# innobackupex -uroot -p123456 --apply-log /mybackups/2017-05-28_21-57-39/ 
[root@desktop7 binlogs]# innobackupex -uroot -p123456 --copy-back /mybackups/2017-05-28_21-57-39/ 
13.修改其属组属主：
chown -R mysql:mysql /data/mydata
启动mysql
查看是否恢复成功
14.使用innobackupex进行增量备份
如何做基于时间点（增量）恢复的数据
首先做一个完全备份：
[root@desktop7 binlogs]# innobackupex --user=root -p123456 /mybackups/
14.查看备份的数据（注意：每一次备份都会产生新的备份数据目录的）：
15.为了做第一次增量备份，插入数据:
mysql -uroot -p123456
use hcx1;
create table tb1(id int);
insert into tb1 values(1),(2);
16.其次，在做第一次增量备份：
[root@desktop7 binlogs]# innobackupex --incremental /mybackups/ --incremental-basedir=/mybackups/2017-05-29_11-39-14/(以第一此备份做为基础)
17. xtrabackup_checkpoints —— 备份类型（如完全或增量）、备份状态（如是否已经为prepared状态）和LSN(日志序列号)范围信息；
[root@desktop7 binlogs]# cat /mybackups/2017-05-29_11-39-14/xtrabackup_checkpoints
backup_type =  full-backuped

from_lsn = 0

to_lsn = 1712180

last_lsn = 1712180

compact = 0
对比：
backup_type =  incremental

from_lsn = 1712180

to_lsn = 1721035

last_lsn = 1721035

compact = 0
17.为了做第二次增量备份，再次插入数据:
mysql -uroot -p123456
create database xiaoxiao;
use xiaoxiao;
create table hehe(Name char(30));
17.1:其次，在做第二次增量备份：  
 innobackupex --incremental /mybackups/  --incremental-basedir=/mybackups/2014-03-07_09-56-26(这个是第一次增量备份的内容)
17.2：假如说这时候我们又做了修改，而没有做增量备份，那么就从要最后一次增量备份中（如下信息的日志及位置）做相关数据恢复：
cat /mybackups/2014-03-07_10-05-20/xtrabackup_binlog_info

master-bin.000002 874            
17.3:那么就又再一次的插入数据（注意此时没有做任何备份）
mysql -uroot -p123456
use hcx1;
insert into tb1(3),(4);
17.4:模拟数据损坏或操作失误：
service mysqld stop
 rm -rf /data/mydata/*
18.1:模拟将数据恢复：
先执行恢复完全备份：
innobackupex --apply-log --redo-only /mybackups/2014-03-07_09-51-29/(初始时的备份)
18.2： 接着执行恢复第一次增量备份：
innobackupex --apply-log --redo-only /mybackups/2014-03-07_09-51-29/  --incremental-dir=/mybackups/2014-03-07_09-56-26/（第一次增量的备份）
18.3：最后执行第二次增量备份
innobackupex --apply-log --redo-only /mybackups/2014-03-07_09-51-29/  --incremental-dir=/mybackups/2014-03-07_10-05-20
18.4：查看几次恢复合并后的文件（可以和之前做对比）：
[root@localhost ~]#  cat /mybackups/2014-03-07_09-51-29/xtrabackup_checkpoints 
18.5：查看完全备份与第二次备份的时间点：
[root@localhost  2014-03-07_09-51-29]# cat  /mybackups/2014-03-07_09-51-29/xtrabackup_binlog_info

master-bin.000002 874           

[root@localhost  2014-03-07_09-51-29]# cat  /mybackups/2014-03-07_10-05-20/xtrabackup_binlog_info

master-bin.000002 874  
18.2：恢复数据（完全备份）
innobackupex --copy-back  /mybackups/2014-03-07_09-51-29/
修改器属主属组：
chown -R mysql:mysql ./*
 查看且导出数据：
mysqlbinlog --start-position=874 /data/binlogs/master-bin.000002

... ...
（出现这个代表成功）INSERT INTO tb1  VALUES (3),(4)

... ...（可能会有报错，报错的话就是mysqlbinlog的路径不对，用安装时的绝对路径例如：/usr/local/mysql/bin/mysqllogbin）
mysqlbinlog --start-position=874 /data/binlogs/master-bin.000002 >  /tmp/inc.sql
18.3
启动服务
4.11 关闭二进制日志：

         MariaDB [hellodb]> set session  sql_log_bin=0;

4.12 恢复刚刚保存在tmp下文件：

         MariaDB [hellodb]> source  /tmp/inc.sql

4.13 开启二进制日志：

         MariaDB [hellodb]> set session  sql_log_bin=1;
查看hellodb中的表是否还原
导入或导出单张表的实现？？？
假如说我想实现期望能够把hellodb中students表中的数据导出来，每一张表都给他单独进行导出。

1.1 将之前的所有备份删除，以免出问题，后备份：
rm  -rf /mybackups/*
innobackupex --user=root /mybackups/
导出表 
innobackupex --apply-log --export /mybackups/2014-03-07_14-16-07/
查看导出的表（看.exp的）：
cd /mybackups/
[root@desktop7 mybackups]# cd 2017-05-29_11-39-14/hcx1/
[root@desktop7 hcx1]# ls
db.opt    hehe.exp  hehe.ibd  tb1.exp  tb1.ibd
hehe.cfg  hehe.frm  tb1.cfg   tb1.frm
导入表（要在mysql服务器上导入来自于其它服务器的某innodb表，需要先在当前服务器上创建一个跟原表表结构一致的表，而后才能实现将表导入）：
mysql -uroot -p123456
use hcx1;
show create table hehe;
mysql> show create table hehe\G;
*************************** 1. row ***************************
       Table: hehe
Create Table: CREATE TABLE `hehe` (
  `name` varchar(20) DEFAULT NULL,
  `sex` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.00 sec)
(可以在另外一个服务器上创建表时直接粘帖)
另外一个服务器（远程连接，可以授权）
create database mydb;
create table 'hh'(粘帖上面的)
查看表结构：
desc hh;
18.4 然后将此表的表空间删除：

MariaDB [mydb]>  ALTER TABLE students DISCARD TABLESPACE;

18.5接下来，将来自于“导出”表的服务器的mytable表的mytable.ibd和mytable.exp文件复制到当前服务器的数据目录：
root@localhost ~]#  cd /mybackups/2014-03-07_14-16-07/hellodb/

[root@localhost  hellodb]# cp students.exp students.ibd /data/mydata/mydb/

[root@localhost  hellodb]# ls /data/mydata/mydb/

db.opt  students.exp  students.frm  students.ibd
修改其属组属主：
chown -R mysql:mysql hehe.*
然后使用如下命令将其导入：
MariaDB [mydb]>  ALTER TABLE students IMPORT TABLESPACE;
查看是否导入成功：
MariaDB [mydb]>  SELECT * FROM students;




















































































































































































































