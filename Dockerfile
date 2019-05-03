FROM entrack/docker-alpine-nginx:alpine35
MAINTAINER Michael Martin <mmartin@encoretg.com>

#----------------------------------------------------
# Base Alpine edge image w/s6 Overlay, Nginx and PHP7
#----------------------------------------------------

RUN apk add --upgrade apk-tools

RUN apk --no-cache --update add \
    php7 \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fpm \
#    php7-fileinfo \
    php7-gd \
    php7-json \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pgsql \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pcntl \
    php7-phar \
    php7-posix \
    php7-session \
#    php7-xdebug \
    php7-xml \
    php7-xml \
    php7-xsl \
    php7-zip \
    php7-zlib \
    libpng \
    libressl2.4-libcrypto

##/
 # Link PHP
 #/
RUN ln -s /usr/bin/php7 /usr/bin/php

##/
 # Install composer
 #/
ENV COMPOSER_HOME=/composer
RUN mkdir /composer \
    && curl -sS https://getcomposer.org/installer | php \
    && mkdir -p /opt/composer \
    && mv composer.phar /opt/composer/composer.phar

##/
 # Install New Relic PHP Agent
 #/
RUN mkdir /tmp/newrelic \
    && cd /tmp/newrelic \
    && wget "http://download.newrelic.com/php_agent/release/$(curl http://download.newrelic.com/php_agent/release/ | grep -ohE 'newrelic-php5-.*?-linux-musl.tar.gz' | cut -f1 -d\")" -O php-agent.tar.gz \
    && gzip -dc php-agent.tar.gz | tar xf - \
    && mkdir -p /opt/newrelic \
    && cp -a "$(ls | grep 'newrelic')/." /opt/newrelic/ \
    && rm -rf /tmp/newrelic

WORKDIR /var/www

##/
 # Copy files
 #/
COPY rootfs /

RUN apk update
