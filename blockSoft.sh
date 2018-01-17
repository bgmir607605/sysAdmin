#!/bin/bash
# Блокирует изменение структуры папки 
cd /mnt/secondDrive/srv/share
chmod -R 755 ПО/
chattr -R +i ПО/

