#!/bin/bash

# Versiones de programas a instalar
PHP_VERSION="5"
NODE_MAJOR=24
USUARIO="josemi"
DB_USER="usprueba"
DB_HOST="localhost"
DB_PASS="usprueba"
# Colores para mostrar los mensajes
COLOR="\e[1;36m"    # Establece el color del texto del mensaje
RESET="\e[0m"       # Resetea los colores a sus colores por defecto

#El primer paso es instalar aplicaciones básicas
echo -e "$COLOR Primero instalaremos algunas aplicaciones básicas $RESET"

sudo apt install build-essential
sudo apt install htop
sudo apt install -y ca-certificates curl gnupg
# Luego instalamos git, otra aplicación básica
echo -e "$COLOR Instalando git y activando el terminal de git en color $RESET"

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
echo -e "$COLOR Creando un certificado autofirmado en localcerts $RESET"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/localcerts/apache.key -out /etc/ssl/localcerts/apache.pem

# Ahora el servidor Apache
echo -e "$COLOR Ahora el servidor Apache y activamos algunos módulos útiles$RESET"
sudo apt install apache2
# Activamos algunos módulos de Apache
sudo a2enmod rewrite ssl headers # mod_rewrite

# Maria DB
echo -e "$COLOR Instalando Maria DB Server$RESET"
sudo apt install mariadb-server

# Añadimos la codificación utf al archivo my.cnf
# Pero primero hacemos una copia de seguridad del mismo
echo -e "$COLOR Añadimos la codificación utf al archivo my.cnf $RESET"
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
echo -e "$COLOR Creamos un usuario para la base de datos$RESET"
sudo mysql  <<EOF
CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$DB_HOST' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo -e "$COLOR ¡Usuario '$DB_USER' creado con éxito!$RESET"



# Instalando php
echo -e "$COLOR Instalando php 8.$PHP_VERSION y algunas extensiones4RESET"
# Este repositorio estará obsoleto pronto
# sudo add-apt-repository ppa:ondrej/php

# Nueva forma de añadir el repositorio
sudo apt-get -y install lsb-release ca-certificates curl
sudo curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
sudo dpkg -i /tmp/debsuryorg-archive-keyring.deb
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
sudo apt-get update


sudo apt install php8.$PHP_VERSION
#Extensiones de php8.5
sudo apt install php8.$PHP_VERSION-{common,bcmath,xml,fpm,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,soap,cgi}
sudo a2enconf php8.$PHP_VERSION-fpm
sudo systemctl reload apache2

# Generando las claves ssh
echo -e "$COLOR Generando las claves ssh $RESET"
mkdir ~/.ssh
ssh-keygen -f ~/.ssh/id_rsa -t rsa -b 4096

# Vamos a instalar Nodejs añadiendo un Nodesource Repository
echo -e "$COLOR Instalando NodeJS $NODE_MAJOR $RESET"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
#Creando el repositorio deb

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install nodejs -y
echo -e "$COLOR Instalada la versión de NodeJS:"
node -v
echo -e "$RESET"
# Instalando Composer
echo -e "$COLOR Instalando Composer $RESET"
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
echo -e "$COLOR"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { 
    echo 'Composer Installer verified'; 
} else { 
    echo 'Composer Installer corrupt';
    unlink('composer-setup.php'); 
} 
echo PHP_EOL;"
echo -e "$RESET"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# PhpMyAdmin - https://idroot.us/install-phpmyadmin-linux-mint-21/
echo -e "$COLOR Instalando PhpMyAdmin $RESET"
sudo apt install software-properties-common apt-transport-https wget ca-certificates gnupg2
sudo apt install phpmyadmin

# Añadimos el usuario al grupo www-data (Cambiar el usuario por el que proceda)
echo -e "$COLOR Añadimos el usuario al grupo www-data y damos permisos de escritura al directorio web $RESET"
sudo usermod -a -G www-data $USUARIO
# Damos permisos de escritura al directorio web
sudo chown -R $USUARIO:www-data /var/www/html
