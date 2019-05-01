#!/bin/bash
DBSERVER_PREFIX='dbserver'
FW_INSTANCE_PREFIX='panw-fw'
sudo exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2> sudo /dev/console) 2>&1
TEMP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
ZONE=$(basename $TEMP)
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
WEB_INSTANCE=$(basename $INSTANCE_NAME)
RAND_NUM=${WEB_INSTANCE:${#WEB_INSTANCE} - 2}
DB_INSTANCE="$DBSERVER_PREFIX$RAND_NUM"
FW_INSTANCE="$FW_INSTANCE_PREFIX$RAND_NUM"
FW_IP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format="value(networkInterfaces[2].networkIP)")
FW_PublicIP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format="value(networkInterfaces[1].accessConfigs[0].natIP)")
DB_IP=$(gcloud compute instances describe $DB_INSTANCE --zone=$ZONE --format="value(networkInterfaces[0].networkIP)")
echo "Is FW up?"
while true
  do
   resp=$(curl -s -S -g --insecure "https://$FW_IP/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT1CU0dMRHIrOWFET0JUNzNaTmRoYmkwdjBkWWM9alUvUjBFTTNEQm93Vmx0OVhFRlNkOXdJNmVwYWk5Zmw4bEs3NjgwMkh5QT0=")
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
sudo mv /etc/wordpress/config-$DB_IP.php /etc/wordpress/config-$FW_PublicIP.php
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
