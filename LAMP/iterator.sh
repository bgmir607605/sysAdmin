#!/bin/bash
list=( $(cat "list") ) 

i=0
for i in "${list[@]}"
do
  ./addDB.sh $i
  ./addDNS.sh $i
  ./addUser.sh $i
done
