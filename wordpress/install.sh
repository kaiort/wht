#!/bin/bash
sudo apt update
sudo apt install -y apache2 ghostscript libapache2-mod-php mariadb-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www

read -p "Geben Sie einen Namen für die WordPress-Installation ein: " install_name
read -p "Geben Sie die Domain für die WordPress-Installation ein: " domain_name
read -p "Geben Sie ein Passwort für den MySQL-Benutzer $install_name@localhost ein: " mysql_password

curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
sudo mv /srv/www/wordpress /srv/www/"$install_name"

# Apache-Konfiguration erstellen
cat <<EOL | sudo tee /etc/apache2/sites-available/"$install_name".conf > /dev/null
<VirtualHost *:80>
    DocumentRoot /srv/www/$install_name
    ServerName $domain_name
    <Directory /srv/www/$install_name>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/$install_name/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOL

sudo a2ensite "$install_name"
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo service apache2 reload

# MySQL-Verbindung als Root-Benutzer, Datenbank, Benutzer erstellen und Berechtigungen erteilen
sudo mysql -u root -e "CREATE DATABASE $install_name;"
sudo mysql -u root -e "CREATE USER '$install_name'@'localhost' IDENTIFIED BY '$mysql_password';"
sudo mysql -u root -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON $install_name.* TO '$install_name'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# MySQL-Server starten
sudo service mysql start

# Kopiere die WordPress-Konfigurationsdatei
sudo -u www-data cp /srv/www/"$install_name"/wp-config-sample.php /srv/www/"$install_name"/wp-config.php

# Datenbank-Zugangsdaten in die WordPress-Konfigurationsdatei eintragen
sudo -u www-data sed -i "s/database_name_here/$install_name/g" /srv/www/"$install_name"/wp-config.php
sudo -u www-data sed -i "s/username_here/$install_name/g" /srv/www/"$install_name"/wp-config.php
sudo -u www-data sed -i "s/password_here/$mysql_password/g" /srv/www/"$install_name"/wp-config.php

# WordPress-Salts generieren und in die Konfigurationsdatei eintragen
sudo -u www-data curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sudo -u www-data tee -a /srv/www/"$install_name"/wp-config.php > /dev/null

# Platzhalter in der wp-config.php-Datei ersetzen
sudo -u www-data sed -i "s/put your unique phrase here/$(curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -v '_wp' | head -n 8)/" /srv/www/"$install_name"/wp-config.php
