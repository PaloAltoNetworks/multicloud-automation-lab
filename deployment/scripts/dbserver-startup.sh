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

# Install and configure database server
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq debconf-utils mariadb-server
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('paloalto@123') WHERE User = 'root';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mysql
sudo mysql -e "CREATE DATABASE Demo;"
sudo mysql -e "CREATE USER 'demouser'@'%' IDENTIFIED BY 'paloalto@123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON Demo.* TO 'demouser'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"