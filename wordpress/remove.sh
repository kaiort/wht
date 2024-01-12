#!/bin/bash

# Funktion zum Deinstallieren einer einzelnen Installation
function uninstall_single {
    read -p "Geben Sie den Namen der WordPress-Installation ein: " install_name

    # Lösche WordPress-Dateien und Konfiguration
    sudo rm -rf /srv/www/"$install_name"
    sudo rm -f /etc/apache2/sites-available/"$install_name".conf

    # Datenbank und Datenbankbenutzer entfernen
    sudo mysql -u root -e "DROP DATABASE IF EXISTS $install_name;"
    sudo mysql -u root -e "DROP USER IF EXISTS '$install_name'@'localhost';"
}

# Funktion zum Fragen, ob Programme entfernt werden sollen
function ask_remove_programs {
    read -p "Möchten Sie die folgenden Programme entfernen: apache2 ghostscript libapache2-mod-php mariadb-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip (J/N)? " answer

    if [[ $answer =~ ^[Jj]$ ]]; then
        # Deinstalliere die Programme
        sudo apt remove --purge -y apache2 ghostscript libapache2-mod-php mariadb-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
        sudo apt autoremove -y
        sudo apt clean
    fi
}

# Aufruf der Funktion zum Deinstallieren einer einzelnen Installation
uninstall_single

# Aufruf der Funktion zum Fragen, ob Programme entfernt werden sollen
ask_remove_programs
