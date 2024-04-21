#!/bin/bash
#XPanel Alireza
echo "Install Dropbear ..."
apt-get -y remove dropbear 1> /dev/null 2> /dev/null
apt-get -y purge dropbear 1> /dev/null 2> /dev/null
apt-get install jq -y
apt-get install dropbear -y

rm -rf /etc/default/dropbear

echo "/bin/false" >> /etc/shells

echo ""

echo "Enter Port Dropbear"
read port

echo "NO_START=0" >> /etc/default/dropbear
echo "DROPBEAR_PORT=$port" >> /etc/default/dropbear
#echo "DROPBEAR_EXTRA_ARGS='-p 442 -p 8080 -p 8484 -p 143 -p 109'" >> /etc/default/dropbear
#echo "DROPBEAR_BANNER='/etc/banner'" >> /etc/default/dropbear
# RSA hostkey file (default: /etc/dropbear/dropbear_rsa_host_key)
echo "DROPBEAR_RSAKEY='/etc/dropbear/dropbear_rsa_host_key'" >> /etc/default/dropbear

# DSS hostkey file (default: /etc/dropbear/dropbear_dss_host_key)
echo "DROPBEAR_DSSKEY='/etc/dropbear/dropbear_dss_host_key'" >> /etc/default/dropbear
# Receive window size - this is a tradeoff between memory and
# network performance
echo "DROPBEAR_RECEIVE_WINDOW=65536" >> /etc/default/dropbear

systemctl daemon-reload
service dropbear start 
service dropbear restart 
sed -i "s/DEFAULT_HOST =.*/DEFAULT_HOST = '127.0.0.1:${port}'/g" /usr/local/bin/wssd
systemctl enable wssd
systemctl restart wssd
sudo mkdir -p /xpanel
curl -o /xpanel/dropbear.sh https://raw.githubusercontent.com/xpanel-cp/Dropbear-ssh/main/xpdropbear.sh
sudo chown -R root:root /xpanel/dropbear.sh
chmod +rx /xpanel/dropbear.sh
cat > /etc/systemd/system/xpdropbear.service <<EOF
[Unit]
Description=XMonitor Dropbear
After=network.target

[Service]
ExecStart=/xpanel/dropbear.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable xpdropbear >/dev/null 2>&1
systemctl start xpdropbear
sed -i "s/PORT_DROPBEAR=.*/PORT_DROPBEAR=$port/g" /var/www/html/app/.env
crontab -l | sed '/dropbear\.sh/d' | crontab -
if [ -f "/var/www/html/dropbear.sh" ]; then
    rm -rf "/var/www/html/dropbear.sh"
fi

echo "Port Connection $port"

echo "DROPBEAR CONFIGURADO."
