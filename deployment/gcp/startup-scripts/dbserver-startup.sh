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

API_KEY="LUFRPT1zWW1BN3NFYnBtaEdmNFovc21HTEN4L21KQU09T2lmZjU0cFhUK1UzYUFyTGJac29tNFFvTFdGSmxIT3pVL3Ezb2JoTE1Tc2E1anc2OEhvR2xDY0gvTGJoeVBYRw=="
FW_INSTANCE="vm-series"
TEMP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
ZONE=$(basename $TEMP)
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
DB_INSTANCE=$(basename $INSTANCE_NAME)
FW_IP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format="value(networkInterfaces[3].networkIP)")
while true
    do 
        resp=$(curl -s -S -g --insecure "https://$FW_IP/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=$API_KEY")
	echo $resp
        if [[ $resp == *"[CDATA[yes"* ]] ; then
            break
        fi
        sleep 10s
    done
while true
  do
   resp=$(curl -s -S -g --insecure "https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/ssh-to-db.cgi")
   echo $resp
   if [[ $resp == *"DB-IP-ADDRESS"* ]] ; then
     break
   fi
   sleep 10s
  done
sudo apt-get update
sudo apt-get -y install debconf-utils &&
echo "mysql-server mysql-server/root_password password paloalto@123" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password paloalto@123" | sudo debconf-set-selections
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y mysql-server
sudo mysql -uroot -ppaloalto@123 -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -uroot -ppaloalto@123 -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -uroot -ppaloalto@123 -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_localhost';"
sudo mysql -uroot -ppaloalto@123 -e "FLUSH PRIVILEGES;"
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mysql
sudo mysql -uroot -ppaloalto@123 -e "CREATE DATABASE Demo;"
sudo mysql -uroot -ppaloalto@123 -e "CREATE USER 'demouser'@'%' IDENTIFIED BY 'paloalto@123';"
sudo mysql -uroot -ppaloalto@123 -e "GRANT ALL PRIVILEGES ON Demo.* TO 'demouser'@'%';"
sudo mysql -uroot -ppaloalto@123 -e "FLUSH PRIVILEGES;"
