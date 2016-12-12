#!/bin/bash

mkdir -p /var/log/cron
file=/var/www/cron.conf

if [ ! -f $file ]; then
    echo '' >> ${file}
fi

crontab ${file}