#!/bin/bash
echo "Install Dropbear ..."
apt-get -y remove dropbear 1> /dev/null 2> /dev/null
apt-get -y purge dropbear 1> /dev/null 2> /dev/null

apt-get install dropbear -y

rm -rf /etc/default/dropbear

echo "/bin/false" >> /etc/shells

echo ""

echo "Enter Port Dropbear"
read port

echo "NO_START=0" >> /etc/default/dropbear
echo "DROPBEAR_PORT=$port" >> /etc/default/dropbear
echo "DROPBEAR_EXTRA_ARGS='-p 442 -p 443 -p 80 -p 8080 -p 8484 -p 143 -p 109'" >> /etc/default/dropbear
#echo "DROPBEAR_BANNER='/etc/banner'" >> /etc/default/dropbear

service dropbear start 
service dropbear restart 

echo "puerto $port agregado"

echo "DROPBEAR CONFIGURADO."
