#!/bin/bash
echo "Add user: $1";
useradd $1  -b /home -m -U -s /bin/false;
echo -e "$2\n$2\n" | passwd $1;

mkdir -p -m 755 /home/$1/$3/public_html;
mkdir -p -m 777 /home/$1/$3/logs;
mkdir -p -m 777 /home/$1/$3/tmp;
chmod 755 /home;
chmod 755 /home/$1;
chmod +t /home/$1/$3/logs;
chmod +t /home/$1/$3/tmp;
chown -R $1:$1 /home/$1;
chmod a-w /home/$1;
usermod -s /bin/bash $1;

conf='/etc/apache2/sites-available/'$3'.conf';
echo "<VirtualHost *:80>" > $conf;
echo "ServerName www.$3" >> $conf;
echo "ServerAlias $3" >> $conf;
echo "ServerAdmin support@$3" >> $conf;
echo "DocumentRoot \"/home/$1/$3/public_html\"" >> $conf;
echo "<Directory />" >> $conf;
echo "Options FollowSymLinks" >> $conf;
echo "AllowOverride None" >> $conf;
echo "</Directory>" >> $conf;
echo "<Directory /home/$1/$3/public_html/>" >> $conf;
echo "Options Indexes FollowSymLinks MultiViews" >> $conf;
echo "AllowOverride All" >> $conf;
echo "Order allow,deny" >> $conf;
echo "allow from all" >> $conf;
echo "Require all granted" >> $conf;
echo "</Directory>" >> $conf;
echo "ErrorLog /home/$1/$3/logs/errors.log" >> $conf;
echo "LogLevel warn" >> $conf;
echo "CustomLog /home/$1/$3/logs/access.log combined" >> $conf;
echo "AssignUserId www-data $1" >> $conf;
echo "php_admin_value open_basedir \"/home/$1/:.\"" >> $conf;
echo "php_admin_value upload_tmp_dir \"/home/$1/$3/tmp\"" >> $conf;
echo "php_admin_value session.save_path \"/home/$1/$3/tmp\"" >> $conf;
echo "</VirtualHost>" >> $conf;  

a2ensite $3;
service apache2 reload;

