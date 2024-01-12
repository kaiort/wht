#!/bin/bash

# Stopp Apache und MySQL
sudo service apache2 stop
sudo service mysql stop

# Lösche Apache-Sites und deaktiviere Mod Rewrite
sudo a2dissite *
sudo a2dismod rewrite

# Lösche WordPress-Installation und Konfigurationsdatei
sudo rm -rf /srv/www/*
sudo rm -f /etc/apache2/sites-available/*
sudo rm -f /etc/apache2/sites-enabled/*
sudo rm -f /etc/apache2/conf-available/*
sudo rm -f /etc/apache2/conf-enabled/*
sudo rm -f /etc/apache2/mods-available/*
sudo rm -f /etc/apache2/mods-enabled/*

# Deinstalliere Apache, MySQL und PHP
sudo apt remove --purge -y apache2 mysql-server php
sudo apt autoremove -y
sudo apt clean

# Starte Apache und MySQL neu
sudo service apache2 start
sudo service mysql start
