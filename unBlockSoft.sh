#!/bin/bash
# Разблокирует изменение структуры папки 
cd /mnt/secondDrive/srv/share
chattr -R -i ПО/
chmod -R 777 ПО/


