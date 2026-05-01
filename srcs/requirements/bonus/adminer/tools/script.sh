#!/bin/sh

mkdir -p /var/www/html

# Download stable version 4.8.1 which doesn't have the namespace issue
wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O /var/www/html/index.php

cd /var/www/html

php -S 0.0.0.0:80