#!/bin/sh

# create the socket directory — MariaDB needs this on Alpine
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# initialize the database directory if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
fi

# run setup SQL via bootstrap
mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# start mariadb in foreground as PID 1
exec mysqld --user=mysql