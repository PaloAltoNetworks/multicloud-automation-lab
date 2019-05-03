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

API_KEY='LUFRPT1zWW1BN3NFYnBtaEdmNFovc21HTEN4L21KQU09T2lmZjU0cFhUK1UzYUFyTGJac29tNFFvTFdGSmxIT3pVL3Ezb2JoTE1Tc2E1anc2OEhvR2xDY0gvTGJoeVBYRw=='
DB_INSTANCE='db-vm'
FW_INSTANCE='vm-series'
TEMP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
ZONE=$(basename $TEMP)
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
WEB_INSTANCE=$(basename $INSTANCE_NAME)
FW_IP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format="value(networkInterfaces[2].networkIP)")
FW_PublicIP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format="value(networkInterfaces[1].accessConfigs[0].natIP)")
DB_IP=$(gcloud compute instances describe $DB_INSTANCE --zone=$ZONE --format="value(networkInterfaces[0].networkIP)")
echo "Is FW up?"
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
sudo apt-get install -y apache2
sudo apt-get install -y wordpress
sudo ln -sf /usr/share/wordpress /var/www/html/wordpress
sudo gzip -d /usr/share/doc/wordpress/examples/setup-mysql.gz
while true
 do
  resp=$(mysql -udemouser -ppaloalto@123 -h $DB_IP -e 'show databases')
  if [[ $resp == *"Demo"* ]]; then
     break
  fi
 sleep 5s
done
sudo bash /usr/share/doc/wordpress/examples/setup-mysql -n Demo -t $DB_IP $DB_IP
sudo sed -i "s/define('DB_USER'.*/define('DB_USER', 'demouser');/g" /etc/wordpress/config-$DB_IP.php
sudo sed -i "s/define('DB_PASSWORD'.*/define('DB_PASSWORD', 'paloalto@123');/g" /etc/wordpress/config-$DB_IP.php
#sudo mv /etc/wordpress/config-$DB_IP.php /etc/wordpress/config-$FW_PublicIP.php
sudo mv /etc/wordpress/config-$DB_IP.php /etc/wordpress/config-default.php
sudo wget -O /usr/lib/cgi-bin/guess-sql-root-password.cgi https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/guess-sql-root-password.cgi
sudo chmod +x /usr/lib/cgi-bin/guess-sql-root-password.cgi
sudo sed -i "s/DB-IP-ADDRESS/$DB_IP/g" /usr/lib/cgi-bin/guess-sql-root-password.cgi
sudo wget -O /usr/lib/cgi-bin/ssh-to-db.cgi https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/ssh-to-db.cgi
sudo chmod +x /usr/lib/cgi-bin/ssh-to-db.cgi
sudo sed -i "s/DB-IP-ADDRESS/$DB_IP/g" /usr/lib/cgi-bin/ssh-to-db.cgi
sudo wget -O /var/www/html/sql-attack.html https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/sql-attack.html
sudo ln -sf /etc/apache2/conf-available/serve-cgi-bin.conf /etc/apache2/conf-enabled/serve-cgi-bin.conf
sudo ln -sf /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load
sudo systemctl restart apache2
