从服务器与主服务器建立连接
change master to master_host='172.25.13.6',master_user='hcx',master_password='westos',master_log_file='mysql-bin.0000001',master_log_pos=106;
mysql读写分离
yum install glibc.i686 
快速创建镜像模版 qemu-img create -f qcow2 -b gg.img oo
cd /var/lib/libvirt/images/																																			
虚拟机模版制作
cd /etc/ssh
rm -fr ssh_host_*
cd /etc/udev/rules.d
rm -fr 70-*
vim /etc/sysconfig/network-script/ifcfg-eth0
DEVICE="eth0"
BOOTPROTO=none
IPADDR="172.25.13.2"
ONBOOT=yes
TYPE=Ethernet
PREFIX=24
cd /etc/yum.repo.d/hcx.repo
[hcx]
name=hcx
baseurl=http://172.25.13.250/hcx
enabled = 1
gpgcheck = 1







