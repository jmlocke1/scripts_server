#!/bin/bash

# Información sacada de la página: https://www.datacamp.com/es/tutorial/install-mongodb-on-ubuntu
# Instalando MondoDB 8 en Ubuntu 24.04.5
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt update
sudo apt install mongodb-org
sudo systemctl start mongod
# Si solamente se va a acceder a MongoDB desde el propio servidor, no hay que hacer nada.
# Si se quiere acceder a MongoDB desde cualquier servidor, hay que hacer lo siguiente:
#       - Editar el fichero de configuración
#           sudo nano /etc/mongod.conf
#       - Busca la sección net y cambia o añade la IP bindIp: 0.0.0.0 para permitir conexiones desde cualquier IP