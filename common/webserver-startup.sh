#!/bin/bash
temp=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
zone=$(basename $temp)
firewall=$(gcloud compute instances describe vm-series --zone=$zone --format="value(networkInterfaces[2].networkIP)")
public_ip=$(gcloud compute instances describe vm-series --zone=$zone --format="value(networkInterfaces[1].accessConfigs[0].natIP)")
database_ip=$(gcloud compute instances describe db-vm --zone=$zone --format="value(networkInterfaces[0].networkIP)")

echo "Is FW up?"
while true
  do
   resp=$(curl -s -S -g --insecure "https://$firewall/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT1reXlBaWVoVmJoSUJ4K1RPejEwMUpveFUzRWM9MFNNYTI2OWVNaGpKblB0R1JLUjYxRnRFaGFWQkgzV08wNkt6NSt3bHNZcz0=")
   echo $resp
   if [[ $resp == *"[CDATA[yes"* ]] ; then
     break
   fi
  sleep 10s
done
#echo "Download content"
#while true
#  do
#   resp=$(curl -s -S -g --insecure "https://$firewall/api/?type=op&cmd=<request><content><upgrade><download><latest></latest></download></upgrade></content></request>&key=LUFRPT1reXlBaWVoVmJoSUJ4K1RPejEwMUpveFUzRWM9MFNNYTI2OWVNaGpKblB0R1JLUjYxRnRFaGFWQkgzV08wNkt6NSt3bHNZcz0=")
#   echo $resp
#   if [[ $resp == *"success"* ]] ; then
#     break
#   fi
#  sleep 10s
#done
#echo "Install content"
#while true
#  do
#   resp=$(curl -s -S -g --insecure "https://$firewall/api/?type=op&cmd=<request><content><upgrade><install><version>latest</version></install></upgrade></content></request>&key=LUFRPT1reXlBaWVoVmJoSUJ4K1RPejEwMUpveFUzRWM9MFNNYTI2OWVNaGpKblB0R1JLUjYxRnRFaGFWQkgzV08wNkt6NSt3bHNZcz0=")
#   echo $resp
#   if [[ $resp == *"success"* ]] ; then
#     break
#   fi
#  sleep 10s
#done

while true
  do
   resp=$(curl -s -S -g --insecure "https://raw.githubusercontent.com/PaloAltoNetworks/multicloud-automation-lab/gcp/common/ssh-to-db.cgi")
   echo $resp
   if [[ $resp == *"DB-IP-ADDRESS"* ]] ; then
     break
   fi
  sleep 10s
done
apt-get update
apt-get install -y apache2 wordpress
ln -sf /usr/share/wordpress /var/www/html/wordpress
gzip -d /usr/share/doc/wordpress/examples/setup-mysql.gz
while true
 do
  resp=$(mysql -udemouser -pPaloAlto123! -h $database_ip -e 'show databases')
  if [[ $resp == *"Demo"* ]]; then
     break
  fi
 sleep 5s
done
bash /usr/share/doc/wordpress/examples/setup-mysql -n Demo -t $database_ip $database_ip
sed -i "s/define('DB_USER'.*/define('DB_USER', 'demouser');/g" /etc/wordpress/config-$database_ip.php
sed -i "s/define('DB_PASSWORD'.*/define('DB_PASSWORD', 'PaloAlto123!');/g" /etc/wordpress/config-$database_ip.php
mv /etc/wordpress/config-$database_ip.php /etc/wordpress/config-$public_ip.php
wget -O /usr/lib/cgi-bin/guess-sql-root-password.cgi https://raw.githubusercontent.com/PaloAltoNetworks/multicloud-automation-lab/gcp/common/guess-sql-root-password.cgi
chmod +x /usr/lib/cgi-bin/guess-sql-root-password.cgi
sed -i "s/DB-IP-ADDRESS/$database_ip/g" /usr/lib/cgi-bin/guess-sql-root-password.cgi
wget -O /usr/lib/cgi-bin/ssh-to-db.cgi https://raw.githubusercontent.com/PaloAltoNetworks/multicloud-automation-lab/gcp/common/ssh-to-db.cgi
chmod +x /usr/lib/cgi-bin/ssh-to-db.cgi
sed -i "s/DB-IP-ADDRESS/$database_ip/g" /usr/lib/cgi-bin/ssh-to-db.cgi
wget -O /var/www/html/sql-attack.html https://raw.githubusercontent.com/PaloAltoNetworks/multicloud-automation-lab/gcp/common/sql-attack.html
ln -sf /etc/apache2/conf-available/serve-cgi-bin.conf /etc/apache2/conf-enabled/serve-cgi-bin.conf
ln -sf /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load
systemctl restart apache2
