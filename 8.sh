linux的mysql远程授权：
grant all privileges on *.* to 'root'@'172.25.254.175' identified by '123456' with grant option;
flush privileges
在172.25.254.175上登陆：
(前期：172.25.254.174的防火墙处于关闭状态)
mysql -uroot -p123456 -h 172.25.254.174



修改密码：
修改MySQL的登录设置：
?
1
	
# vi /etc/my.cnf

在[mysqld]的段中加上一句：skip-grant-tables 保存并且退出vi。

3．重新启动mysqld

	
# /etc/init.d/mysqld restart ( service mysqld restart )

4．登录并修改MySQL的root密码

	
mysql> USE mysql ;
mysql> UPDATE user SET Password = password ( 'new-password' ) WHERE User = 'root' ;
mysql> flush privileges ;
mysql> quit
yum源
二、如果出现GPG key retrieval failed: [Errno 14] Could not open/read file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6问题，请在线安装epel，

yum install http://mirrors.sohu.com/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm





