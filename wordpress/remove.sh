#!/bin/bash

# Funktion zum Deinstallieren einer einzelnen Installation
function uninstall_single {
    read -p "Geben Sie den Namen der WordPress-Installation ein: " install_name

    # Stopp Apache und MySQL
    sudo service apache2 stop
    sudo service mysql stop

    # Lösche WordPress-Dateien und Konfiguration
    sudo rm -rf /srv/www/"$install_name"
    sudo rm -f /etc/apache2/sites-available/"$install_name".conf

    # Datenbank und Datenbankbenutzer entfernen
    sudo mysql -u root -e "DROP DATABASE IF EXISTS $install_name;"
    sudo mysql -u root -e "DROP USER IF EXISTS '$install_name'@'localhost';"
}

# Funktion zum Deinstallieren aller Installationen
function uninstall_all {
    # Stopp Apache und MySQL
    sudo service apache2 stop
    sudo service mysql stop

    # Lösche alle WordPress-Installationen und Konfigurationen
    sudo rm -rf /srv/www/*
    sudo rm -f /etc/apache2/sites-available/*

    # Datenbanken und Datenbankbenutzer aller Installationen entfernen
    for db in $(sudo mysql -u root -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)"); do
        sudo mysql -u root -e "DROP DATABASE IF EXISTS $db;"
        sudo mysql -u root -e "DROP USER IF EXISTS '$db'@'localhost';"
    done

    # Deinstalliere Apache, MySQL und PHP
    sudo apt remove --purge -y apache2 mariadb-server php
    sudo apt autoremove -y
    sudo apt clean
}

read -p "Möchten Sie eine einzelne Installation (I) oder alle (A) entfernen? " choice

if [[ $choice =~ ^[Ii]$ ]]; then
    uninstall_single
elif [[ $choice =~ ^[Aa]$ ]]; then
    uninstall_all
else
    echo "Ungültige Auswahl. Bitte geben Sie 'I' für einzelne Installation oder 'A' für alle ein."
fi
