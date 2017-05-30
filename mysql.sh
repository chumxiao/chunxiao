#!/bin/bash
yum install libaio* jemalloc* -y
groupadd mysql
useradd -r -s /sbin/nologin -g mysql mysql
mkdir /data
chown -R mysql:mysql /data
mkdir /data/mydata
chown -R mysql:mysql /data/mydata
cd /root
tar zxf mariadb-10.1.11-linux-x86_64.tar.gz 
mkdir /usr/local/mysql
mv mariadb-10.1.11-linux-x86_64/* /usr/local/mysql/
chown -R mysql:mysql /usr/local/mysql/*
cd /usr/local/mysql 
scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/mydata/
cp support-files/mysql.server /etc/init.d/mysqld
sed -i "41a\datadir =/data/mydata" /etc/my.cnf
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysql_secure_installation /usr/bin/mysql_secure_installation
/etc/init.d/mysqld start



