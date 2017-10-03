#!/usr/bin/with-contenv bash

environment="$(curl -s http://169.254.169.254/latest/user-data | grep 'export ENVIRONMENT' | cut -f2 -d=)"
export ENVIRONMENT=${environment}
vars=$(curl "${ENVIRONMENT_URL}/get?key=${ENVIRONMENT}_ENV_VARS&&version=${VERSION}")

#----------------------------------------------------------
# Add the container environment variables to bash sessions
#----------------------------------------------------------

pattern='if [ -f /opt/envars.sh ]; then source /opt/envars.sh; fi'
source=/opt/envars.sh
app_env_source=/opt/app_environment

if [ ! -f ${source} ]; then
    touch ${source} && chmod 0644 ${source}
fi

if [ ! -f ${app_env_source} ]; then
  touch ${app_env_source} & chmod 0644 ${app_env_source}
fi

echo "#!/bin/bash" > ${source}

if ! grep -Fxq '$pattern' /root/.bashrc ; then
    echo -e "${pattern}" >> /root/.bashrc
fi

echo ${environment} > ${app_env_source}

#----------------------------------------------------------
# Add them as fastcgi_params
#----------------------------------------------------------
param_file=/etc/nginx/conf.d/params

if [ ! -f ${param_file} ]; then
  touch ${param_file} && chmod 0644 ${param_file}
fi

#----------------------------------------------------------
# Generate the php-fpm config file
#----------------------------------------------------------

conf=/etc/php7/php-fpm.d/www.conf

if [ ! -f ${conf} ]; then
    touch ${conf} && chmod 0644 ${conf}
fi

# Clear and set the file for environment variables
#echo "[www]" > ${conf}

#----------------------------------------------------------
# Generate the php-cli ini file
#----------------------------------------------------------

ini=/etc/php7/conf.d/envars.ini

if [ ! -f ${ini} ]; then
    touch ${ini} && chmod 0644 ${ini}
fi

# Empty the ini file
echo "" > ${ini}

#----------------------------------------------------------
# Generate a Laravel 5 Environment file
#----------------------------------------------------------

lfiveenv="/var/www/.env"

if [ ! -f ${lfiveenv} ]; then
    touch ${lfiveenv}
fi

echo "" > ${lfiveenv}

#----------------------------------------------------------
# Generate a laravel 4.2 Environment file
#----------------------------------------------------------

envname=""
if [ ! "$ENVIRONMENT" == "production" ]; then
    envname=".$ENVIRONMENT"
fi

lfourenv="/var/www/.env${envname}.php"

if [ ! -f ${lfourenv} ]; then
    touch ${lfourenv}
fi

echo "<?php return [" > ${lfourenv}

#----------------------------------------------------------
# Add the container environment variables to all files
#----------------------------------------------------------

echo "Generating Environment Variables"

for var in ${vars}
do
    var=${var//[$'\'\t\r\n ']}
    name=$(echo $var | cut -f1 -d=)
    value=$(echo $var | cut -f2 -d=)

    echo "export ${name}='${value}'" >> ${source}
    echo "env[${name}] = '${value}'" >> ${conf}
    echo "env[${name}] = '${value}'" >> ${ini}
    echo "'${name}' => '${value}'," >> ${lfourenv}
    echo "${name}='${value}'" >> ${lfiveenv}
    echo "fastcgi_param ${name} ${value};" >> ${param_file}
done

#----------------------------------------------------------
# Close the laravel 4.2 Environment file
#----------------------------------------------------------

echo "];" >> ${lfourenv}