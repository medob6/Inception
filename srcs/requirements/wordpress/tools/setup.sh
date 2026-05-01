#!/bin/sh

# Load passwords from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# download wp-cli
wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /usr/local/bin/wp

# go to wordpress directory
mkdir -p /var/www/html
chmod -R 755 /var/www/html
cd /var/www/html

# wait for mariadb to be ready
until mysql -h mariadb -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1" >/dev/null 2>&1; do
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
        --title="Inception" \
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

    # Install and activate astra theme
    wp theme install astra --activate \
        --allow-root \
        --path=/var/www/html

    # Install and activate Redis Object Cache plugin
    wp plugin install redis-cache --activate \
        --allow-root \
        --path=/var/www/html

    # Configure Redis Object Cache settings
    wp config set WP_REDIS_HOST redis \
        --allow-root \
        --path=/var/www/html

    wp config set WP_REDIS_PORT 6379 \
        --allow-root \
        --path=/var/www/html

    wp config set WP_CACHE true \
        --allow-root \
        --path=/var/www/html

    wp redis enable \
        --allow-root \
        --path=/var/www/html

    chown -R nobody:nobody /var/www/html
fi


# launch php-fpm in foreground — this becomes PID 1
exec php-fpm82 -F