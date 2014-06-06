# !/bin/bash --login -x
# Generic Dev Vagrant box set up
# PHP, Ruby

if [ `id -u` -ne 0 ]; then
  echo "You need root privileges to run this script"
  exit 1
fi
 
# cd to home
cd ~
 
# exit if php is already installed
which php && { echo "Tools already installed."; exit 0; }

# update
apt-get update
 
# debconf utils
apt-get install -y debconf-utils

# parameters
echo "grub-pc grub-pc/kopt_extracted boolean true" | debconf-set-selections
echo "grub-pc grub2/linux_cmdline string" | debconf-set-selections
echo "grub-pc grub-pc/install_devices multiselect /dev/sda" | debconf-set-selections
echo "grub-pc grub-pc/install_devices_failed_upgrade boolean true" | debconf-set-selections
echo "grub-pc grub-pc/install_devices_disks_changed multiselect /dev/sda" | debconf-set-selections
echo "mysql-server mysql-server/root_password password admin" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password admin" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password admin" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password admin" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password admin" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive
 
# vagrant grub fix
dpkg-reconfigure -f noninteractive grub-pc
 
# upgrade
sudo apt-get -y upgrade
# basic tools
apt-get install -y wget
apt-get install -y curl
apt-get install -y git
apt-get install -y vim
apt-get install -y cron
apt-get install -y python-software-properties
apt-get install -y python
apt-get install -y g++
apt-get install -y make
apt-get install -y build-essential
apt-get install -y openssl
apt-get install -y subversion
 
# apache2
apt-get install -y apache2
echo "ServerName ubuntu.dev" | tee /etc/apache2/conf-available/httpd.conf
a2enconf httpd
a2enmod rewrite
a2enmod headers
a2enmod filter
a2enmod expires
a2enmod include
 
# php
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-dev
 
# mysql
apt-get install -q -y mysql-server
apt-get install -y libapache2-mod-auth-mysql
apt-get install -y php5-mysql
 
# sqlite
apt-get install -y sqlite3
 
# phpmyadmin
apt-get install -q -y phpmyadmin
 
# imagemagick
apt-get install -y imagemagick
 
# php extensions
apt-get install -y php-apc
apt-get install -y php5-curl
apt-get install -y php5-intl
apt-get install -y php5-xdebug
apt-get install -y php5-xmlrpc
apt-get install -y php5-xsl
apt-get install -y php5-sqlite
apt-get install -y php5-imagick
 
#Php Configuration
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 50M/" /etc/php5/apache2/php.ini
sed -i "s/short_open_tag = On/short_open_tag = Off/" /etc/php5/apache2/php.ini
sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php5/apache2/php.ini
sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php5/cli/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php5/apache2/php.ini
sed -i "s/_errors = Off/_errors = On/" /etc/php5/apache2/php.ini
sed -i "s/:error_log = Off/_errors = On/" /etc/php5/apache2/php.ini
#sudo bindfs -o perms=0775,mirror=vagrant,group=www-data /home/vagrant/www /var/www

# composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
 
# pear - uncomment if you need pear
#apt-get install -y php-pear
# phpunit, apigen, phing, and phpQA tools
#pear config-set auto_discover 1
#pear install --alldeps pear.phpunit.de/PHPUnit
#pear install --alldeps pear.apigen.org/apigen
#pear install --alldeps pear.phpqatools.org/phpqatools
#pear channel-discover pear.phing.info
#pear config-set preferred_state alpha
#pear install --alldeps phing/phing
#pear config-set preferred_state stable
# apigen temporary fix
#mkdir /usr/share/php/Texy
#ln -s /usr/share/php/texy/src/texy.php /usr/share/php/Texy/texy.php
  
# restart apache
service apache2 restart
 
# ruby dependencies
apt-get install -y libreadline6
apt-get install -y libreadline6-dev
apt-get install -y zlib1g
apt-get install -y zlib1g-dev
apt-get install -y libssl-dev
apt-get install -y libyaml-dev
apt-get install -y libsqlite3-dev
apt-get install -y libxml2-dev
apt-get install -y libxslt1-dev
apt-get install -y autoconf
apt-get install -y libc6-dev
apt-get install -y libncurses5-dev
apt-get install -y automake
apt-get install -y libtool
apt-get install -y bison
apt-get install -y pkg-config
apt-get install -y libmysqlclient-dev
apt-get install -y libpq-dev
 
# rvm
curl -L get.rvm.io | bash -s stable --auto-dotfiles
# reload to get rvm running:
source /etc/profile.d/rvm.sh # running script during vagrant provision as root 
source ~/.bash_profile # when running script manually as vagrant user

# ruby
rvm install 2.0.0
rvm --default use 2.0.0
 
# ruby on rails
gem install rails -v 4.0.0 --no-document
 
# compass sass
gem update --system
gem install compass --no-document
 
# nodejs
apt-get install -y nodejs npm
# Debian based systems renamed nodejs due to package conflicts. Insert hack here.
sudo ln -s /usr/bin/nodejs /usr/bin/node 
# less
sudo npm install -g less
 
# java and ant
apt-get install -y openjdk-7-jre
apt-get install -y openjdk-7-jdk
apt-get install -y ant
 
# cleanup
apt-get autoremove -y
apt-get update
apt-get upgrade -y
apt-get autoclean
 
# create virtual host
make_vhost () {
cat <<- __EOF__
    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
 
        ServerName localhost
 
        DirectoryIndex index.html index.htm index.php
        DocumentRoot /vagrant/public
 
        <Directory /vagrant/public/>
            Options Indexes FollowSymlinks MultiViews
            AllowOverride All
            Order allow,deny
            Allow from all
            Require all granted
        </Directory>
 
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
 
        ErrorLog /vagrant/.logs/error.log
        CustomLog /vagrant/.logs/access.log combined
    </VirtualHost>
__EOF__
}

# set default virtual host
make_vhost > /etc/apache2/sites-available/000-default.conf

# create directories
mkdir -vp /vagrant/.logs
mkdir -vp /vagrant/public
 
# log files
touch /vagrant/.logs/error.log
touch /vagrant/.logs/access.log
 
service apache2 restart
