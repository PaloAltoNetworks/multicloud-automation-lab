#!/usr/bin/env bash

# Copyright 2019 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# For use on Debian 9 (Stretch) servers

# Check for Internet connectivity
while true
    do 
        resp=$(curl -s -S "http://captive.apple.com")
	echo $resp
        if [[ $resp == *"Success"* ]] ; then
            break
        fi
        sleep 10s
    done

# Install and configure web server
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq apache2 wordpress
sudo ln -sf /usr/share/wordpress /var/www/html/wordpress
sudo cat > /etc/wordpress/config-default.php << EOF
<?php
# Created by /usr/share/doc/wordpress/examples/setup-mysql 
define('DB_NAME', 'Demo');
define('DB_USER', 'demouser');
define('DB_PASSWORD', 'paloalto@123');
define('DB_HOST', '10.5.3.5');
define('SECRET_KEY', 'UtqouIbh65q92QYevFJzth5Kuya3GKozJzmOq4Mv0mevSmgtlW');
define('WP_CONTENT_DIR', '/var/lib/wordpress/wp-content');
?>
EOF
sudo chown root:www-data /etc/wordpress/config-default.php
sudo systemctl restart apache2
