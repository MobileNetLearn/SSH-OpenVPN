#!/bin/bash
cd
# Change to Time GMT+7
ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
cd
service ssh restart

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# Install Command
cd
apt-get -y install ufw
apt-get -y install sudo

# set repo
echo "deb http://httpredir.debian.org/debian wheezy main contrib non-free" >>  /etc/apt/sources.list
echo "deb http://security.debian.org/ wheezy/updates main contrib non-free" >>  /etc/apt/sources.list
echo "deb http://packages.dotdeb.org wheezy all" >>  /etc/apt/sources.list
echo "deb http://download.webmin.com/download/repository sarge contrib" >>  /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >>  /etc/apt/sources.list
wget "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/dotdeb.gpg"
wget "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# update
apt-get update

# install webserver
apt-get -y install nginx
apt-get -y install nginx php5-fpm

# install essential package
apt-get -y install nano iptables dnsutils openvpn screen whois ngrep unzip unrar
apt-get -y install nmap nano iptables sysv-rc-conf o  penvpn vnstat apt-file
apt-get -y install libexpat1-dev libxml-parser-perl
apt-get -y install build-essential

# install neofetch
echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | sudo tee -a /etc/apt/sources.list
curl -L "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" -o Release-neofetch.key && sudo apt-key add Release-neofetch.key && rm Release-neofetch.key
apt-get update
apt-get install neofetch

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

#text gambar
apt-get install boxes

# Setting Vnstat
vnstat -u -i eth0
chown -R vnstat:vnstat /var/lib/vnstat
service vnstat restart

# text pelangi
sudo apt-get install ruby -y
sudo gem install lolcat

# Install Web Server
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by kunphiphit</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

echo "clear" >> .bashrc
echo 'echo -e "\e[34m========= Script Debian OS 32 & 64 -bit =========\e[0m"' >> .bashrc
echo 'echo -e "\e[35m-------------------------------------------------------------------------\e[0m"' >> .bashrc
echo 'echo -e ""' >> .bashrc

# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://github.com/kunphiphit/kunphiphit/blob/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/443.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -A FORWARD -s 10.8.0.0/255.255.255.0 -j ACCEPT 
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -t nat -A POSTROUTING -s 10.8.0.0/255.255.255.0 -j SNAT --to-source $MYIP
iptables-save > /etc/sysconfig/iptables
sed -i 's/eth0/venet0/g' /etc/sysconfig/iptables
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/iptables"
chmod +x /etc/network/if-up.d/iptables
service openvpn restart

# config client openvpn
cd /etc/openvpn/
wget -O client.ovpn "https://raw.githubusercontent.com/gmchoke/A/master/wget -O client.ovpn "https://raw.githubusercontent.com/gmchoke/A/master/True-Dtac.ovpn"
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`;
sed -i s/xxxxxxxxx/$MYIP/g /etc/openvpn/True-Dtac.ovpn;
cp True-Dtac.ovpn /home/vps/public_html/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://github.com/kunphiphit/kunphiphit/blob/master/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://github.com/kunphiphit/kunphiphit/blob/master/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="bannerssh"/g' /etc/default/dropbear
service ssh restart
service dropbear restart

# install vnstat gui
#cd /home/vps/public_html/
#wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
#tar xf vnstat_php_frontend-1.5.1.tar.gz
#rm vnstat_php_frontend-1.5.1.tar.gz
#mv vnstat_php_frontend-1.5.1 vnstat
#cd vnstat
#sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
#sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
#sed -i 's/Internal/Internet/g' config.php
#sed -i '/SixXS IPv6/d' config.php
#sed -i "s/\$locale = 'en_US.UTF-8';/\$locale = 'en_US.UTF+8';/g" config.php
#cd

# install fail2ban
apt-get -y install fail2ban;
service fail2ban restart

# Install Squid 
apt-get -y install squid3 
cp /etc/squid3/squid.conf /etc/squid3/squid.conf.orig 
wget -O /etc/squid3/squid.conf "https://scripkguza.000webhostapp.com/KGUZA-ALL-SCRIP/squid3.conf" 
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`; 
sed -i s/xxxxxxxxx/$MYIP/g /etc/squid3/squid.conf; 
service squid3 restart 

# install webmin
cd
wget -O webmin-current.deb http://prdownloads.sourceforge.net/webadmin/webmin-current.deb
dpkg -i --force-all webmin-current.deb
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
apt-get update
apt-get install -y webmin
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
apt-get -y --force-yes -f install libxml-parser-perl
service webmin restart
service vnstat restart

# Install Dos Deflate
apt-get -y install dnsutils dsniff
wget https://github.com/kunphiphit/kunphiphit/blob/master/ddos-deflate-master.zip
unzip master.zip
cd ddos-deflate-master
./install.sh
cd

#  download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/menu.sh"
wget -O 1 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/adduser.sh"
wget -O 2 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/delete.sh"
wget -O 3 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/deleteauto.sh"
wget -O 4 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/viewuser.sh"
wget -O 5 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/restart.sh"
wget -O 6 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/speedtest.py"
wget -O 7 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/viewlogin.sh"
wget -O 8 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/info.sh"
wget -O 9 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/about.sh"
wget -O 10 "https://raw.githubusercontent.com/kunphiphit/kunphiphit/master/timereboot.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x 1
chmod +x 2
chmod +x 3
chmod +x 4
chmod +x 5
chmod +x 6
chmod +x 7
chmod +x 8
chmod +x 9
chmod +x 10

# Restart Service
cd
chown -R www-data:www-data /home/vps/public_html
service cron restart
service nginx start
service php5-fpm start
service vnstat restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "======================================="  
echo "Service Auto Script VPS By CAT-IDC" | lolcat
echo ""  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/" | lolcat
echo "Host  :  http://$MYIP" | lolcat
echo "Squid3  : 8080" | lolcat
echo "OpenSSH  : 143" | lolcat
echo "Dropbear : 22" | lolcat
echo "Config OpenVPN ( ดาวโหลดไฟล์ http://$MYIP/Client.ovpn )" | lolcat
echo "Timezone : Asia/Bangkok" | lolcat
echo "Fail2Ban : [ on ]" | lolcat
echo "vnstat   : http://$MYIP/vnstat/" | lolcat
echo "Ipv6     : [ off ]" | lolcat
echo "Power By : kunphiphit" | lolcat

echo "[[ หมายเหตุ ]] 👇👇👇" | lolcat
echo "Config VPN จำกัด 1" | lolcat
echo "Auto SSH จำกัด 2" | lolcat
echo ">> รายชื่อบันชีจะถูกเเบนอัตโนมัติเมื่อต่อเกินกำหนด" | lolcat
echo "ออโต้รีบูท 00:00" | lolcat
echo "CREATED BY kunphiphit [ VPN&SSH ] VPS - SCRIPT INSTALLER" | lolcat
echo "พิมพ์ >> menu << Enrte" | lolcat
echo "Reboot VPS " | lolcat
echo ""  | tee -a log-install.txt
echo "========================================"
