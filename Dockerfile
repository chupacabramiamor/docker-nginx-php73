FROM phpearth/php:7.3-nginx

ARG PUID=1000
ARG PGID=1000

RUN apk update && \
    apk add curl npm yarn git openssh-client sqlite php7.3-sqlite3 php7.3-pdo_sqlite php7.3-gd && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --1 && \
    apk --no-cache add shadow &&\
    /usr/sbin/usermod -u $PUID www-data && /usr/sbin/groupmod -g $PGID www-data &&\
    chown www-data:www-data /var/www

RUN npm install -g gulp

COPY ./docker/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html/htdocs
