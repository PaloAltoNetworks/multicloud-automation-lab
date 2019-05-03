#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
FW_IP=10.5.0.4
while true
 do
  resp=$(curl -s -S -g --insecure "https://$FW_IP/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT1IMzNWWDNnWGloMmhnUmdoNnNwcmJ5WXlMOEk9T2lmZjU0cFhUK1UzYUFyTGJac29tK3k1bFd6Z29vV2RBSndOMDhYWGVLcGk1bEJaNmR2QndRbU8rY0ZPQmtlaw==")
  if [[ $resp == *\"[CDATA[yes\"* ]] ; then
    break
  fi
 sleep 10s
done
sudo apt-get update
sudo apt-get -y install debconf-utils
echo \"mysql-server mysql-server/root_password password paloalto@123\" | sudo debconf-set-selections
echo \"mysql-server mysql-server/root_password_again password paloalto@123\" | sudo debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
mysql -uroot -ppaloalto@123 -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\"
mysql -uroot -ppaloalto@123 -e \"DELETE FROM mysql.user WHERE User='';\"
mysql -uroot -ppaloalto@123 -e \"DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_localhost';\"
mysql -uroot -ppaloalto@123 -e \"FLUSH PRIVILEGES;\"
sudo sed -i \"s/.*bind-address.*/bind-address = 0.0.0.0/\" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
mysql -uroot -ppaloalto@123 -e \"CREATE DATABASE Demo;\"
mysql -uroot -ppaloalto@123 -e \"CREATE USER 'demouser'@'%' IDENTIFIED BY 'paloalto@123';\"
mysql -uroot -ppaloalto@123 -e \"GRANT ALL PRIVILEGES ON Demo.* TO 'demouser'@'%';\"
mysql -uroot -ppaloalto@123 -e \"FLUSH PRIVILEGES;\"