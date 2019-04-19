#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
temp=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
zone=$(basename $temp)
FW_IP=$(gcloud compute instances describe vm-series --zone=$zone --format="value(networkInterfaces[3].networkIP)")
while true
    do
        resp=$(curl -s -S -g --insecure "https://$FW_IP/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT1reXlBaWVoVmJoSUJ4K1RPejEwMUpveFUzRWM9MFNNYTI2OWVNaGpKblB0R1JLUjYxRnRFaGFWQkgzV08wNkt6NSt3bHNZcz0=")
	echo $resp
        if [[ $resp == *"[CDATA[yes"* ]] ; then
            break
        fi
        sleep 10s
    done
while true
  do
   resp=$(curl -s -S -g --insecure "https://raw.githubusercontent.com/PaloAltoNetworks/multicloud-automation-lab/gcp/common/ssh-to-db.cgi")
   echo $resp
   if [[ $resp == *"DB-IP-ADDRESS"* ]] ; then
     break
   fi
   sleep 10s
  done
sudo apt-get update
sudo apt-get -y install debconf-utils
echo "mysql-server mysql-server/root_password password PaloAlto123!" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password PaloAlto123!" | sudo debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
mysql -uroot -ppaloalto@123 -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -uroot -ppaloalto@123 -e "DELETE FROM mysql.user WHERE User='';"
mysql -uroot -ppaloalto@123 -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_localhost';"
mysql -uroot -ppaloalto@123 -e "FLUSH PRIVILEGES;"
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mysql
mysql -uroot -ppaloalto@123 -e "CREATE DATABASE IF NOT EXISTS Demo;"
mysql -uroot -ppaloalto@123 -e "CREATE USER 'demouser'@'%' IDENTIFIED BY 'PaloAlto123!';"
mysql -uroot -ppaloalto@123 -e "GRANT ALL PRIVILEGES ON Demo.* TO 'demouser'@'%';"
mysql -uroot -ppaloalto@123 -e "FLUSH PRIVILEGES;"
