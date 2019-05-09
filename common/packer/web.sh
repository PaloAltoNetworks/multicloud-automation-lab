#!/bin/sh
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq apache2 wordpress
sudo ln -sf /usr/share/wordpress /var/www/html/wordpress
sudo mv /tmp/config-default.php /etc/wordpress/config-default.php
sudo chown root:www-data /etc/wordpress/config-default.php