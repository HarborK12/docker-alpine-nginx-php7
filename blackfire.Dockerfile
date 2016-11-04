FROM harbork12/docker-alpine-nginx
MAINTAINER Michael Martin <mmartin@fuelingbrands.com>

#----------------------------------------------------
# Base Alpine edge image w/s6 Overlay, Nginx and PHP7
#----------------------------------------------------

##/
 # Install PHP
 #/
RUN apk --no-cache --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
    php7 \
    php7-fpm \
    php7-xml \
    php7-pgsql \
    php7-pdo_pgsql \
    php7-mysqli \
    php7-pdo_mysql \
    php7-mcrypt \
    php7-opcache \
    php7-gd \
    php7-curl \
    php7-json \
    php7-phar \
    php7-openssl \
    php7-ctype \
    php7-mbstring \
    php7-zip \
    php7-dom \
    php7-xdebug \
    php7-pcntl \
    php7-posix \
    php7-session
#   php7-readline

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

##/
 # Install Blackfire PHP Probe
 #/
RUN mkdir /conf.d \
    && version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini



##/
 # Copy files
 #/
COPY rootfs /