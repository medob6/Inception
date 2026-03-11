#!/bin/sh

# download wp-cli
wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /usr/local/bin/wp

# go to wordpress directory
mkdir -p /var/www/html
cd /var/www/html

# wait for mariadb to be ready
until mysql -h mariadb -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SELECT 1" 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done

echo "MariaDB is ready!"

# only install wordpress if not already done
if [ ! -f "/var/www/html/wp-config.php" ]; then

    wp core download --allow-root --locale=en_US

    wp config create \
        --allow-root \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=mariadb \
        --path=/var/www/html

    wp core install \
        --allow-root \
        --url=$DOMAIN_NAME \
        --title="My Inception Site" \
        --admin_user=$WP_ADMIN \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --skip-email \
        --path=/var/www/html

    wp user create $WP_USER $WP_USER_EMAIL \
        --allow-root \
        --user_pass=$WP_USER_PASSWORD \
        --role=subscriber \
        --path=/var/www/html

    echo "WordPress installed successfully!"

fi

chown -R nobody:nobody /var/www/html

# launch php-fpm in foreground — this becomes PID 1
exec php-fpm82 -F