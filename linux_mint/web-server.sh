#!/bin/bash

#El primer paso es instalar aplicaciones básicas
sudo apt install build-essential
sudo apt install htop
sudo apt install curl
# Luego instalamos git, otra aplicación básica
sudo apt install git
#Activamos la terminal de git en color
# El código y la explicación se encuentra en: 
# https://github.com/magicmonty/bash-git-prompt
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
echo '

if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.bash-git-prompt/gitprompt.sh
fi

' >> ~/.bashrc

# Creamos un certificado autofirmado en localcerts
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/localcerts/apache.key -out /etc/ssl/localcerts/apache.pem

# Ahora el servidor Apache
sudo apt install apache2
# Activamos algunos módulos de Apache
sudo a2enmod rewrite ssl headers # mod_rewrite

# Maria DB
sudo apt install mariadb-server

# Añadimos la codificación utf al archivo my.cnf
# Pero primero hacemos una copia de seguridad del mismo
sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.back
sudo echo '

[client]
default-character-set=utf8mb4

[mysql]
default-character-set=utf8mb4

[mysqld]
character-set-client-handshake = false # force encoding to utf8
character-set-server=utf8mb4
collation-server = utf8mb4_unicode_ci

[mysqld_safe]
default-character-set=utf8mb4

' >> /etc/mysql/my.cnf

# Instalando php 8.1
# apt install php8.1
#Extensiones de php8.1
# apt install php8.1-{bcmath,xml,fpm,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi}

# Instalando php 8.2
# sudo add-apt-repository ppa:ondrej/php
# sudo apt update
# sudo apt install php8.2
#Extensiones de php8.2
# sudo apt install php8.2-{bcmath,xml,fpm,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi}
# sudo a2enconf php8.2-fpm

# Instalando php 8.3
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.3
#Extensiones de php8.3
sudo apt install php8.3-{bcmath,xml,fpm,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi}
sudo a2enconf php8.3-fpm
sudo systemctl reload apache2

# Generando las claves ssh
mkdir ~/.ssh
ssh-keygen -f ~/.ssh/id_rsa -t rsa -b 4096

# Vamos a instalar Nodejs 18.x añadiendo un Nodesource Repository
### Node.js 20 ###
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
#Creando el repositorio deb
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install nodejs -y

# Instalando Composer

curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { 
    echo 'Composer Installer verified'; 
} else { 
    echo 'Composer Installer corrupt';
    unlink('composer-setup.php'); 
} 
echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# PhpMyAdmin - https://idroot.us/install-phpmyadmin-linux-mint-21/
sudo apt install software-properties-common apt-transport-https wget ca-certificates gnupg2
sudo apt install phpmyadmin

# Añadimos el usuario al grupo www-data (Cambiar el usuario por el que proceda)
sudo usermod -a -G www-data josemi_admin
