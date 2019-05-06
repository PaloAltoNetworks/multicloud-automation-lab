#!/bin/sh
sudo apt-get update
sudo apt-get install -y apache2 wordpress
sudo ln -sf /usr/share/wordpress /var/www/html/wordpress
sudo mv /tmp/config-default.php /etc/wordpress/config-default.php
sudo chown root:www-data /etc/wordpress/config-default.php