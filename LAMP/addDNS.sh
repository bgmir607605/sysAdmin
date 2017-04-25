#!/bin/bash
############################
# 25.04.2017               #
# Mironov Andrey           #
# Добавление записи в BIND #
############################
function help(){
        echo "Скрипт для добавления новой записи в прямую и обратную доменные зоны BIND"
		echo "В качестве аргумента передаётся доменное имя нижнего уровня"
		echo "Например, добавление домена test.example :"
		echo "	"$0" test"
		echo "При этом зона .example прописывается внутри скрипта в переменой zone"
		echo ""
		echo "Конфигурация скрипта:"
		echo "	zone='.bpt.loc'"
		echo "	fZone='/etc/bind/flz.bpt.zone'"
		echo "	rZone='/etc/bind/rlz.bpt.zone'"
		echo "	network='192.168.137.'"
		echo "	host='254'"
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

domain=$1
zone='.bpt.loc'
fZone='/etc/bind/flz.bpt.zone'
rZone='/etc/bind/rlz.bpt.zone'
network='192.168.137.'
host='254'

# Запись прямой зоны
echo $domain"	IN	A	"$network$host >> $fZone
echo "" >> $fZone

# Запись обратной зоны
echo $host"	IN	PTR	"$domain$zone >> $rZone
echo "" >> $rZone

rndc reload