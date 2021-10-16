#!/bin/bash

DOCKER_HTTP_PORT=$(grep DOCKER_HTTP_PORT docker/.env | cut -d '=' -f 2-)
CLIENT_NAME=$(grep CLIENT_NAME docker/.env | cut -d '=' -f 2-)
PROJECT_NAME=$(grep PROJECT_NAME docker/.env | cut -d '=' -f 2-)
DN="${PROJECT_NAME}.${CLIENT_NAME}"
CONTAINER_NAME="${CLIENT_NAME}.${PROJECT_NAME}"
NGINX_CONF="/etc/nginx/sites-available/$CLIENT_NAME"

if [ ! -f $NGINX_CONF ]; then
    sudo touch $NGINX_CONF
    sudo ln -s "/etc/nginx/sites-available/${CLIENT_NAME}" /etc/nginx/sites-enabled/
fi

sed -e "s/\${DN}/${DN}/" -e "s/\${DOCKER_HTTP_PORT}/${DOCKER_HTTP_PORT}/" docker/nginx.conf.stub | sudo tee -a $NGINX_CONF
service nginx restart

if [[ -z $(grep "${DN}" /etc/hosts) ]]; then
    echo "127.0.0.1 ${DN}" | sudo tee -a /etc/hosts
fi

# docker build . -t lead9-nginx-php73 --build-arg PUID=$(id -u) --build-arg PGID=$(id -g)
docker build . -t lead9-nginx-php73 --build-arg PUID=$(id -u)
docker create -p=$DOCKER_HTTP_PORT:80 -v=$(pwd):/var/www/html --name=$CONTAINER_NAME lead9-nginx-php73
docker start $CONTAINER_NAME

# Вход в контейнер
# docker exec -it -u=$(id -u) $CONTAINER_NAME sh
