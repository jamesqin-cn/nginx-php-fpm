#!/bin/sh

DOC_ROOT=/data/wwwroot/html

# init configure 
#curl http://git.config.svc/config/wordpress.web/raw/master/wp-config.php > $DOC_ROOT/wp-config.php 2>/dev/null

sed -i s/{{SERVER_NAME}}/${SERVER_NAME:-localhost}/g /etc/nginx/nginx.conf
sed -i s/{{CGI_PARAM_SERVER_NAME}}/${CGI_PARAM_SERVER_NAME:-$SERVER_NAME}/g /etc/nginx/nginx.conf
sed -i s/{{CGI_PARAM_HTTPS}}/${CGI_PARAM_HTTPS:-off}/g /etc/nginx/nginx.conf

sed -i s/{{PM_MAX_CHILDREN}}/${PM_MAX_CHILDREN:-64}/g /etc/php7/php-fpm.d/www.conf
sed -i s/{{PM_START_SERVERS}}/${PM_START_SERVERS:-2}/g /etc/php7/php-fpm.d/www.conf
sed -i s/{{PM_MIN_SPARE_SERVERS}}/${PM_MIN_SPARE_SERVERS:-1}/g /etc/php7/php-fpm.d/www.conf
sed -i s/{{PM_MAX_SPARE_SERVERS}}/${PM_MAX_SPARE_SERVERS:-2}/g /etc/php7/php-fpm.d/www.conf

# parent container startup script
mkdir -p /data/logs/
/start.sh
