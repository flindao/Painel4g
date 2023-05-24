#!/bin/bash
clear
echo -e "\n\033[1;36mINICIANDO INSTALAÇÃO \033[1;33mAGUARDE..."
apt-get install lolcat -y &>/dev/null
apt-get install figlet -y &>/dev/null
apt-get install figlet boxes -y &>/dev/null
clear
system=$(cat /etc/issue.net)
date=$(date '+%Y-%m-%d <> %H:%M:%S')
echo ""
sleep 3s
function inst_base {
apt update > /dev/null 2>&1
apt dist-upgrade -y > /dev/null 2>&1
apt install apache2 -y > /dev/null 2>&1
apt install cron curl unzip dirmngr apt-transport-https -y > /dev/null 2>&1
add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
apt update > /dev/null 2>&1
apt install php7.4 libapache2-mod-php7.4 php7.4-xml php7.4-mcrypt php7.4-curl php7.4-mbstring -y > /dev/null 2>&1
systemctl restart apache2
apt-get install mariadb-server -y > /dev/null 2>&1
cd || exit
mysqladmin -u root password "$pwdroot"
mysql -u root -p"$pwdroot" -e "UPDATE mysql.user SET Password=PASSWORD('$pwdroot') WHERE User='root'"
mysql -u root -p"$pwdroot" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$pwdroot" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$pwdroot" -e "FLUSH PRIVILEGES"
mysql -u root -p"$pwdroot" -e "CREATE DATABASE net;"
mysql -u root -p"$pwdroot" -e "GRANT ALL PRIVILEGES ON root.* To 'root'@'localhost' IDENTIFIED BY '$pwdroot';"
mysql -u root -p"$pwdroot" -e "FLUSH PRIVILEGES"
echo '[mysqld]
max_connections = 1000' >> /etc/mysql/my.cnf
apt install php7.4-mysql -y > /dev/null 2>&1
phpenmod mcrypt
systemctl restart apache2
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
apt install php7.4-ssh2 -y > /dev/null 2>&1
php -m | grep ssh2 > /dev/null 2>&1
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
cd /var/www/html || exit
wget https://raw.githubusercontent.com/flindao/painel/main/painel4g/internet4g.zip > /dev/null 2>&1
apt-get install unzip > /dev/null 2>&1
unzip insternet4g.zip > /dev/null 2>&1
chmod -R 777 /var/www/html
rm internet4g.zip index.html > /dev/null 2>&1
(echo yes; echo yes; echo yes; echo yes) | composer install > /dev/null 2>&1
(echo yes; echo yes; echo yes; echo yes) | composer require phpseclib/phpseclib:~2.0 > /dev/null 2>&1
systemctl restart mysql
clear
sed -i "s;dominio;$IP;g" /var/www/html/net.sql > /dev/null 2>&1
sleep 1
if [[ -e "/var/www/html/net.sql" ]]; then
    mysql -h localhost -u root -p"$pwdroot" --default_character_set utf8 conecta4g < /var/www/html/conecta.sql > /dev/null 2>&1
    rm /var/www/html/net.sql > /dev/null 2>&1
else
    clear
    echo -e "\033[1;31m ERRO CRÍTICO\033[0m"
    sleep 2
exit;
fi
}

function phpmadm {
cd /usr/share || exit
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.zip > /dev/null 2>&1
unzip phpMyAdmin-5.1.0-all-languages.zip > /dev/null 2>&1
mv phpMyAdmin-5.1.0-all-languages phpmyadmin
chmod -R 0755 phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
systemctl restart apache2
rm phpMyAdmin-5.1.0-all-languages.zip
cd /root || exit
}
function fun_swap {
swapoff -a
rm -rf /bin/ram.img > /dev/null 2>&1
fallocate -l 4G /bin/ram.img > /dev/null 2>&1
chmod 600 /bin/ram.img > /dev/null 2>&1
mkswap /bin/ram.img > /dev/null 2>&1
swapon /bin/ram.img > /dev/null 2>&1
echo 50  > /proc/sys/vm/swappiness
echo '/bin/ram.img none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null 2>&1
sleep 2
}

function tst_bkp {
cd || exit
sed -i "s;1020;$pwdroot;g" /var/www/html/conexao.php > /dev/null 2>&1
}
clear

IP=$(wget -qO- ipv4.icanhazip.com)
echo "America/Sao_Paulo" > /etc/timezone
ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime > /dev/null 2>&1
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
clear
echo ""
read -p "DIGITE SUA SENHA ROOT: " pwdroot
echo "root:$pwdroot" | chpasswd
echo -e "\n\033[1;36mINICIANDO INSTALAÇÃO \033[1;33mAGUARDE..."
sleep 6
clear
echo "INSTALANDO DEPENDÊNCIAS"
echo "AGUARDE..."
sleep 2
inst_base
phpmadm
fun_swap
tst_bkp
clear
echo ""
echo -e "\033[1;36m SEU PAINEL:\033[1;37m http://$IP/\033[0m"
echo -e "\033[1;36m USUÁRIO:\033[1;37m admin\033[0m"
echo -e "\033[1;36m SENHA:\033[1;37m admin\033[0m"
echo ""
echo -e "\033[1;36m PHPMYADMIN:\033[1;37m http://$IP/phpmyadmin\033[0m"
echo -e "\033[1;36m USUÁRIO:\033[1;37m root\033[0m"
echo -e "\033[1;36m SENHA:\033[1;37m $pwdroot\033[0m"
echo ""
echo -e "\033[1;33m MAIS INFORMAÇÕES \033[1;31m(\033[1;36mTELEGRAM\033[1;31m): \033[1;37m@oogeniohacker\033[0m"
echo ""
echo -ne "\n\033[1;31mENTER \033[1;33mpara retornar...\033[1;32m! \033[0m"; read
sed -i "s;upload_max_filesize = 2M;upload_max_filesize = 64M;g" /etc/php/7.4/apache2/php.ini > /dev/null 2>&1
sed -i "s;post_max_size = 8M;post_max_size = 64M;g" /etc/php/7.4/apache2/php.ini > /dev/null 2>&1
cat /dev/null > ~/.bash_history && history -c
clear
exit
e = 64M;g" /etc/php/7.4/apache2/php.ini > /dev/null 2>&1
cat /dev/null > ~/.bash_history && history -c
clear
exit
