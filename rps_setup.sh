#!/bin/bash

cd /root

# 关闭“您在 /var/spool/mail/root 中有新邮件”提示
echo "unset MAILCHECK">> /etc/profile
source /etc/profile
cat /dev/null > /var/spool/mail/root

# 设置yum缓存
sed -i "s/keepcache=0/keepcache=1/" /etc/yum.conf
echo "yum cachedir = /var/cache/yum"
rm /var/cache/yum/* -rf

# 安装epel
yum install -y epel-release

sed -i "s/^#baseurl/baseurl/" /etc/yum.repos.d/epel.repo
sed -i "s/^metalink/#metalink/" /etc/yum.repos.d/epel.repo
yum install -y xz

# 挂载D盘
yum install -y ntfs-3g

mkdir /D && mount /dev/sdb1 /D

cat >> /etc/fstab <<EOF
/dev/sdb1 /D
EOF

# 安装OpenConnect
wget https://raw.githubusercontent.com/god4/ocserv/master/install_script.sh
sed -i "s/reboot/#reboot/" install_script.sh
sed -i "s/echo '#reboot'/echo 'completed'/" install_script.sh

chmod +x install_script.sh
./install_script.sh
mv install_script.sh anyconnect/

# 配置Apache httpd
yum install -y perl-CGI

mkdir /D/www
mkdir /D/www/cgib
/bin/cp -rf /var/www/html/* /D/www/
/bin/cp -rf /var/www/cgi-bin/* /D/www/cgib/
sed -i "s/\/var\/www\/html/\/D\/www/g" /etc/httpd/conf/httpd.conf
sed -i "s/\/var\/www/\/D\/www/g" /etc/httpd/conf/httpd.conf
sed -i "s/\/cgi-bin/\/cgib/g" /etc/httpd/conf/httpd.conf
sed -i "s/\/var\/www\/html/\/D\/www/g" /D/www/cgib/up.pl
sed -i "s/\/var\/www\/html/\/D\/www/g" /root/anyconnect/user_add.sh

wget https://raw.githubusercontent.com/god4/ocserv/master/up.pl -O /D/www/cgib/up.pl
sed -i "s/\/var\/www\/html/\/D\/www/g" /D/www/cgib/up.pl
chmod +x /D/www/cgib/up.pl

chmod +777 /D/www
chcon -R -t httpd_sys_rw_content_t /D/www

service httpd stop
service httpd start

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
firewall-cmd --zone=public --add-port=80/tcp --permanent

# 安装Cloud Torrent
wget -N --no-check-certificate https://www.xuanlove.download/sh/cloudt.sh
chmod +x cloudt.sh
./cloudt.sh

mkdir /D/cloudt
sed -i "s/\/etc\/cloudtorrent\/downloads/\/D\/cloudt/g" /etc/cloudtorrent/cloud-torrent.json
sed -i "s/\"EnableUpload\": true,/\"EnableUpload\": false,/g" /etc/cloudtorrent/cloud-torrent.json

echo "/etc/cloudtorrent/cloud-torrent -p 8000 -l -a ct:passwd -c /etc/cloudtorrent/cloud-torrent.json>> /etc/cloudtorrent/ct.log 2>&1 &" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
firewall-cmd --zone=public --add-port=8000/tcp --permanent

# 重启
echo "reboot"
reboot
