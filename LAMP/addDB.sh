#!/bin/bash
##################################################
# 25.04.2017                                     #
# Mironov Andrey                                 #
# Добавление новой базы данных и её пользователя #
##################################################
function help(){
	echo "Справка"
	exit 0
}

if [ $# -eq 0 ]; then
	help
fi

if [ $# -eq 1 ]; then
	if [ $1 == '-h' ]; then
		help
	fi

	if [ $1 == '--help' ]; then
                help
        fi
fi

u='root'
p='mysqlRootPass'
username=$1
userpass='*97E7471D816A37E38510728AEA47440F9C6E2585'
prefix='dp_'

echo "Создаю БД "$prefix$username


echo "create database "$prefix$username";" | mysql -u $u -p$p
echo "GRANT ALL PRIVILEGES ON "$prefix$username".* TO '"$username"'@'%';" | mysql -u $u -p$p   
echo "UPDATE mysql.user SET Password = '"$userpass"' WHERE user.Host = '%' AND user.User = '"$username"';" | mysql -u $u -p$p   
echo "FLUSH PRIVILEGES;" | mysql -u $u -p$p   


