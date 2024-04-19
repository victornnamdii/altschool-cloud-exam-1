#!/usr/bin/env bash

export COMPOSER_ALLOW_SUPERUSER=1
export DB_DATABASE=example_database #change to your preferred database name
export DB_USERNAME=example_user #change to your preferred username
export DB_PASSWORD=password #change to your preferred password
export DB_CONNECTION=mysql


echo "Updating Repository Index..."
apt -y update
clear

echo "Installing Apache..."
apt install -y apache2
clear

echo "Adjusting Firewall.."
ufw allow ssh
ufw allow in "Apache Full"
clear

echo "Enabling Apache on boot up..."
systemctl enable apache2
clear

echo "Installing MySQL..."
apt install -y mysql-server
clear

echo "Configuring MySQL DB..."
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_DATABASE;"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL ON $DB_DATABASE.* TO '${DB_USERNAME}'@'%';"

echo "Installing PHP and it's required extensions..."
add-apt-repository -y  ppa:ondrej/php
apt install -y php8.3 libapache2-mod-php php-mysql php-xml php-curl php-zip unzip
clear

clear

if ! [ -f ~/laravel ]; then
	echo "Cloning Laravel Repo from GitHub..."
	git clone https://github.com/laravel/laravel.git
	clear
fi

echo "Setting Up Project"
rm -rf /var/www/html/*
cp -r laravel/* /var/www/html/
clear

if ! [ -f /usr/local/bin/composer ]; then
	echo "Installing Composer..."
	wget https://getcomposer.org/download/2.6.6/composer.phar
	chmod u+x composer.phar
	mv composer.phar /usr/local/bin/composer
	chown vagrant /usr/local/bin/composer
fi
clear

echo "Installing App Dependencies..."
cd /var/www/html/
composer update
composer install
clear

echo "Configuring App Variables..."
bash -c "echo -e APP_KEY= > .env"
bash -c "echo APP_ENV=local >> .env"
bash -c "echo -e DB_CONNECTION=$DB_CONNECTION >> .env"
bash -c "echo -e DB_USERNAME=$DB_USERNAME >> .env"
bash -c "echo -e DB_PASSWORD=$DB_PASSWORD >> .env"
bash -c "echo -e DB_DATABASE=$DB_DATABASE >> .env"
php artisan key:generate
php artisan migrate:refresh
clear

echo "Changing Default Apache DirectoryIndex..."
sed -i 's@DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm@DirectoryIndex /public/index.php@g' /etc/apache2/mods-enabled/dir.conf
clear

echo "Restarting Apache Service..."
systemctl restart apache2

echo "Setting correct permissions for files..."
chmod -R  755 /var/www/html/*
chown -R vagrant:vagrant /var/www/html/*
clear

echo "LAMP stack successfully Installed!!"

