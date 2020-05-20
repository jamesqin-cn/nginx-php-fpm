FROM nginx:mainline-alpine

MAINTAINER ngineered <support@ngineered.co.uk>

ENV php_conf /etc/php7/php.ini 
ENV fpm_conf /etc/php7/php-fpm.d/www.conf

RUN echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /etc/apk/repositories && \
    echo "http://mirrors.aliyun.com/alpine/latest-stable/community/" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache bash \ 
	    openssh-client \
	    wget \
	    nginx \
	    supervisor \
	    curl \
	    git \
	    php7-fpm \
	    php7-pdo \
	    php7-pdo_mysql \
	    php7-mysqlnd \
	    php7-mysqli \
	    php7-mcrypt \
	    php7-mbstring \
	    php7-ctype \
	    php7-zlib \
	    php7-gd \
	    php7-exif \
	    php7-intl \
	    php7-sqlite3 \
	    php7-pdo_pgsql \
	    php7-pgsql \
	    php7-xml \
	    php7-xsl \
	    php7-curl \
	    php7-openssl \
	    php7-iconv \
	    php7-json \
	    php7-phar \
	    php7-soap \
	    php7-dom \
	    php7-zip \
	    php7-session \
	    php7-redis \
	    php7-fileinfo \
	    python \
	    python-dev \
	    py2-pip \
	    augeas-dev \
	    openssl-dev \
	    ca-certificates \
	    dialog \
	    gcc \
	    musl-dev \
	    linux-headers \
	    libffi-dev &&\
    mkdir -p /etc/nginx && \
    mkdir -p /var/www/app && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    /usr/bin/php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    /usr/bin/php7 -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    /usr/bin/php7 composer-setup.php --install-dir=/usr/bin --filename=composer && \
    /usr/bin/php7 -r "unlink('composer-setup.php');"  && \
    pip install -U pip && \
    pip install -U certbot && \
    mkdir -p /etc/letsencrypt/webrootauth && \
    apk del gcc musl-dev linux-headers libffi-dev augeas-dev python-dev && \
    ln -sf /usr/bin/php7 /usr/bin/php

ADD conf/supervisord.conf /etc/supervisord.conf

# Copy our nginx config
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/* && \
mkdir /var/www/html/
ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
RUN ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# php conf
ADD conf/php.ini /etc/php7/conf.d/php.ini
ADD conf/php-fpm.conf /etc/php7/php-fpm.d/www.conf

# Add Scripts
ADD scripts/entrypoint.sh /entrypoint.sh
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push
ADD scripts/letsencrypt-setup /usr/bin/letsencrypt-setup
ADD scripts/letsencrypt-renew /usr/bin/letsencrypt-renew
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /usr/bin/letsencrypt-setup && chmod 755 /usr/bin/letsencrypt-renew && chmod 755 /start.sh && chmod 755 /entrypoint.sh

# copy in code
ADD src/ /var/www/html/
ADD errors/ /var/www/errors

VOLUME /var/www/html

EXPOSE 443 80

ENTRYPOINT ["/entrypoint.sh"]
