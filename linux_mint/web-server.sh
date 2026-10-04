#!/bin/bash

# Versiones de programas a instalar
PHP_VERSION="5"
NODE_MAJOR=24
USUARIO="josemi"
DB_USER="usprueba"
DB_HOST="localhost"
DB_PASS="usprueba"

#El primer paso es instalar aplicaciones básicas
echo "Primero instalaremos algunas aplicaciones básicas"

sudo apt install build-essential
sudo apt install htop
sudo apt install -y ca-certificates curl gnupg
# Luego instalamos git, otra aplicación básica
echo "Instalando git y activando el terminal de git en color"

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
echo "Creando un certificado autofirmado en localcerts"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/localcerts/apache.key -out /etc/ssl/localcerts/apache.pem

# Ahora el servidor Apache
echo "Ahora el servidor Apache y activamos algunos módulos útiles"
sudo apt install apache2
# Activamos algunos módulos de Apache
sudo a2enmod rewrite ssl headers # mod_rewrite

# Maria DB
echo "Instalando Maria DB Server"
sudo apt install mariadb-server

# Añadimos la codificación utf al archivo my.cnf
# Pero primero hacemos una copia de seguridad del mismo
echo "Añadimos la codificación utf al archivo my.cnf"
sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.back
echo '

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

' | sudo tee -a /etc/mysql/my.cnf

# Creamos un usuario para la base de datos
echo "Creamos un usuario para la base de datos"
sudo mysql  <<EOF
CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$DB_HOST' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "¡Usuario '$DB_USER' creado con éxito!"



# Instalando php
echo "Instalando php 8.$PHP_VERSION y algunas extensiones"
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.$PHP_VERSION
#Extensiones de php8.5
sudo apt install php8.$PHP_VERSION-{common,bcmath,xml,fpm,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi}
sudo a2enconf php8.$PHP_VERSION-fpm
sudo systemctl reload apache2

# Generando las claves ssh
echo "Generando las claves ssh"
mkdir ~/.ssh
ssh-keygen -f ~/.ssh/id_rsa -t rsa -b 4096

# Vamos a instalar Nodejs añadiendo un Nodesource Repository
echo "Instalando NodeJS $NODE_MAJOR"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
#Creando el repositorio deb

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install nodejs -y
echo "Instalada la versión de NodeJS:"
node -v
# Instalando Composer
echo "Instalando Composer"
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
echo "Instalando PhpMyAdmin"
sudo apt install software-properties-common apt-transport-https wget ca-certificates gnupg2
sudo apt install phpmyadmin

# Añadimos el usuario al grupo www-data (Cambiar el usuario por el que proceda)
echo "Añadimos el usuario al grupo www-data y damos permisos de escritura al directorio web"
sudo usermod -a -G www-data $USUARIO
# Damos permisos de escritura al directorio web
sudo chown -R $USUARIO:www-data /var/www/html
