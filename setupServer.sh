#!/bin/bash

#Редактируем список источников APT
#++++++++
#Добавляем зеркала Яндекс
#Добавляем BackPorts
echo 'deb http://mirror.yandex.ru/debian/ jessie main' > /etc/apt/sources.list
echo 'deb-src http://mirror.yandex.ru/debian/ jessie main' >> /etc/apt/sources.list
echo 'deb http://security.debian.org/ jessie/updates main contrib' >> /etc/apt/sources.list
echo 'deb-src http://security.debian.org/ jessie/updates main contrib' >> /etc/apt/sources.list
echo 'deb http://mirror.yandex.ru/debian/ jessie-updates main contrib' >> /etc/apt/sources.list
echo 'deb-src http://mirror.yandex.ru/debian/ jessie-updates main contrib' >> /etc/apt/sources.list
echo 'deb http://httpredir.debian.org/debian jessie-backports main contrib non-free' >> /etc/apt/sources.list
#Обновляем источники
apt-get update
#--------



#Настраиваем сетевые интерфейсы и резолв
#++++++++
echo 'source /etc/network/interfaces.d/*' > /etc/network/interfaces
# The loopback network interface
echo 'auto lo' >> /etc/network/interfaces
echo 'iface lo inet loopback' >> /etc/network/interfaces
# Внешний интерфейс
echo 'allow-hotplug eth0' >> /etc/network/interfaces
echo 'iface eth0 inet static' >> /etc/network/interfaces
echo '	address 192.168.8.10' >> /etc/network/interfaces
echo '	netmask 255.255.255.0' >> /etc/network/interfaces
echo '	network 192.168.8.0' >> /etc/network/interfaces
echo '	broadcast 192.168.8.255' >> /etc/network/interfaces
echo '	gateway 192.168.8.1' >> /etc/network/interfaces
echo '	dns-nameservers 192.168.8.1' >> /etc/network/interfaces
echo '	dns-search bpt.local' >> /etc/network/interfaces
# Внутренний интерфейс
echo 'allow-hotplug eth1' >> /etc/network/interfaces
echo 'iface eth1 inet static' >> /etc/network/interfaces
echo '	address 192.168.137.254' >> /etc/network/interfaces
echo '	netmask 255.255.255.0' >> /etc/network/interfaces
# Перезапускаем сеть
/etc/init.d/networking restart
ifup eth0
ifup eth1
# Прописываем резолв
echo 'domain bpt.local' > /etc/resolv.conf
echo 'search bpt.local' >> /etc/resolv.conf
echo 'nameserver 192.168.137.254' >> /etc/resolv.conf
echo 'nameserver 192.168.8.1' >> /etc/resolv.conf
#--------



# Включаем проброс пакетов
#++++++++
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf
sysctl -p
# Добавляем в автозапуск правило iptables для проброса пакетов между интерфейсами
echo '#!/bin/sh -e' > /etc/rc.local
echo 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local
#--------



# Устанавливаем и настраиваем DHCP
#++++++++
apt-get install isc-dhcp-server
# Конфигурируем
echo 'ddns-update-style none;' > /etc/dhcp/dhcpd.conf
echo 'option domain-name "bpt.local";' >> /etc/dhcp/dhcpd.conf
echo 'option domain-name-servers 192.168.137.254;' >> /etc/dhcp/dhcpd.conf
echo 'default-lease-time 600;' >> /etc/dhcp/dhcpd.conf
echo 'max-lease-time 7200;' >> /etc/dhcp/dhcpd.conf
echo 'log-facility local7;' >> /etc/dhcp/dhcpd.conf
echo 'subnet 192.168.137.0 netmask 255.255.255.0 {' >> /etc/dhcp/dhcpd.conf
echo '  range 192.168.137.1 192.168.137.253;' >> /etc/dhcp/dhcpd.conf
echo '  option domain-name-servers 192.168.137.254;' >> /etc/dhcp/dhcpd.conf
echo '  option routers 192.168.137.254;' >> /etc/dhcp/dhcpd.conf
echo '}' >> /etc/dhcp/dhcpd.conf
# Запускаем
service isc-dhcp-server restart
#--------



# Устанавливаем BIND9 и настраиваем домен
#++++++++
apt-get install bind9 dnsutils
#named.conf.options
echo 'acl mynetwork {192.168.137.0/24; 127.0.0.1; };' > /etc/bind/named.conf.options
echo 'options {' >> /etc/bind/named.conf.options
echo '	directory "/var/cache/bind";' >> /etc/bind/named.conf.options
echo '	auth-nxdomain no;' >> /etc/bind/named.conf.options
echo '	forwarders {192.168.137.254; 8.8.8.8; };' >> /etc/bind/named.conf.options
echo '	listen-on-v6 {none; };' >> /etc/bind/named.conf.options
echo '	allow-query {any; };' >> /etc/bind/named.conf.options
echo '};' >> /etc/bind/named.conf.options
#named.conf.local
echo 'zone "bpt.local" {' > /etc/bind/named.conf.local
echo '	type master;' >> /etc/bind/named.conf.local
echo '	file "/etc/bind/flz.bpt.zone";' >> /etc/bind/named.conf.local
echo '};' >> /etc/bind/named.conf.local
echo 'zone "137.168.192.in-addr.arpa" {' >> /etc/bind/named.conf.local
echo '	type master;' >> /etc/bind/named.conf.local
echo '	file "/etc/bind/rlz.bpt.zone";' >> /etc/bind/named.conf.local
echo '};' >> /etc/bind/named.conf.local
# Прописываем прямую зону
echo '$TTL 30' > /etc/bind/flz.bpt.zone
echo '$ORIGIN bpt.local.' >> /etc/bind/flz.bpt.zone
echo '@	IN	SOA	server.bpt.local. admin.bpt.local. (' >> /etc/bind/flz.bpt.zone
echo '	2016081301; Serial' >> /etc/bind/flz.bpt.zone
echo '	1d; Refresh' >> /etc/bind/flz.bpt.zone
echo '	1h; Retry' >> /etc/bind/flz.bpt.zone
echo '	1w; Expire' >> /etc/bind/flz.bpt.zone
echo '	2h; Negtive Cache TTL' >> /etc/bind/flz.bpt.zone
echo ')' >> /etc/bind/flz.bpt.zone
echo '@	IN	NS	server.bpt.local.' >> /etc/bind/flz.bpt.zone
echo '@	IN 	A	192.168.137.254' >> /etc/bind/flz.bpt.zone
echo 'server	IN	A	192.168.137.254' >> /etc/bind/flz.bpt.zone
echo 'bpt.local	IN	A	192.168.137.254' >> /etc/bind/flz.bpt.zone
echo 'www	IN	CNAME	bpt.local' >> /etc/bind/flz.bpt.zone
# Прописываем обратную зону
echo '$TTL 30' > /etc/bind/rlz.bpt.zone
echo '@	IN	SOA	server.bpt.local.	admin.bpt.local. (' >> /etc/bind/rlz.bpt.zone
echo '	2016081301 ; Serial' >> /etc/bind/rlz.bpt.zone
echo '	1d ; Refresh' >> /etc/bind/rlz.bpt.zone
echo '	1h ; Retry' >> /etc/bind/rlz.bpt.zone
echo '	1w ; Expire' >> /etc/bind/rlz.bpt.zone
echo '	2h ; Negative Cache TTL' >> /etc/bind/rlz.bpt.zone
echo ')' >> /etc/bind/rlz.bpt.zone
echo '@	IN	NS	bpt.local.' >> /etc/bind/rlz.bpt.zone
echo '254	IN	PTR	server.bpt.local.' >> /etc/bind/rlz.bpt.zone
# Проверим на ошибки
named-checkconf -z
# Обновим зоны
rndc reload
# Прописать ещё раз резолв
# bla-bla-bla
# Проверяем
nslookup bpt.local
nslookup 192.168.137.254
#--------



# Устанавливаем примочки
#ssh
apt-get install openssh-server

#apache2
# Апач ругается на домен .local
apt-get install apache2 
apt-get install apache2-mpm-itk
service apache2 restart
#mySQL
#настроить бинд из сети
apt-get install mysql-server
#php
apt-get install php5
#phpmyadmin
apt-get install phpmyadmin
#vsftpd
apt-get install vsftpd
echo 'listen=YES' > /etc/vsftpd.conf
echo 'anonymous_enable=NO' >> /etc/vsftpd.conf
echo 'local_enable=YES' >> /etc/vsftpd.conf
echo 'write_enable=YES' >> /etc/vsftpd.conf
echo 'dirmessage_enable=YES' >> /etc/vsftpd.conf
echo 'xferlog_enable=YES' >> /etc/vsftpd.conf
echo 'connect_from_port_20=YES' >> /etc/vsftpd.conf
echo 'ascii_upload_enable=YES' >> /etc/vsftpd.conf
echo 'ascii_download_enable=YES' >> /etc/vsftpd.conf
echo 'ftpd_banner=Welcome to our FTP service.' >> /etc/vsftpd.conf
echo 'chroot_local_user=YES' >> /etc/vsftpd.conf
echo 'secure_chroot_dir=/var/run/vsftpd' >> /etc/vsftpd.conf
echo 'pam_service_name=vsftpd' >> /etc/vsftpd.conf
echo 'rsa_cert_file=/etc/ssl/certs/vsftpd.pem' >> /etc/vsftpd.conf
echo 'file_open_mode=0755' >> /etc/vsftpd.conf
echo 'local_umask=0' >> /etc/vsftpd.conf
echo 'seccomp_sandbox=NO' >> /etc/vsftpd.conf

#настроить шару на samba
