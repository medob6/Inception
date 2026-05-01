FROM alpine:3.22

RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-pdo \
    php82-pdo_mysql \
    php82-json \
    php82-curl \
    php82-ctype \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-pecl-redis \
    php82-xml \
    php82-zip \
    php82-phar \
    php82-tokenizer \
    wget \
    curl \
    unzip \
    mariadb-client

RUN echo "memory_limit=256M" > /etc/php82/conf.d/memory.ini
RUN ln -s /usr/bin/php82 /usr/bin/php
RUN mkdir -p /var/www/html
RUN chown -R nobody:nobody /var/www/html
RUN rm -f /var/www/html/wp-config.php
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 9000

CMD ["/setup.sh"]