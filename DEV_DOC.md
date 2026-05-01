# DEV_DOC.md — Developer Documentation

## Project Overview

This is a Docker Compose-based infrastructure project that runs a complete WordPress stack (Nginx + WordPress/PHP-FPM + MariaDB) in isolated containers. All services are built from scratch using Alpine Linux 3.22, with no pre-built Docker Hub images.

### Architecture

```
┌─────────────────────┐
│   Host Machine      │
│                     │
│  ┌─────────────┐   │
│  │   Nginx     │   │ ← Port 443 exposed
│  │ (Container) │   │
│  └──────┬──────┘   │
│         │          │
│  ┌──────▼────────┐ │
│  │  WordPress/   │ │
│  │  PHP-FPM      │ │
│  │ (Container)   │ │
│  └──────┬────────┘ │
│         │          │
│  ┌──────▼────────┐ │
│  │   MariaDB     │ │
│  │ (Container)   │ │
│  └───────────────┘ │
│                     │
│  Docker Network:    │
│  inception (bridge) │
│                     │
└─────────────────────┘
```

---

## Prerequisites

### System Requirements

- Linux/Mac/WSL2 environment
- **Docker** — Version 20.10+
- **Docker Compose** — Version 2.0+
- **Make** — For automation
- **Git** (optional, for version control)
- At least 2GB disk space
- Network access for downloading Alpine packages

### Verification

```bash
# Check Docker installation
docker --version
# Expected: Docker version 20.10+

# Check Docker Compose
docker compose version
# Expected: Docker Compose version v2.0+

# Check Make
make --version
# Expected: GNU Make 4.0+
```

---

## Project Structure

```
inception/
├── Makefile                          # Automation commands
├── README.md                         # Project overview
├── USER_DOC.md                      # User documentation
├── DEV_DOC.md                       # Developer documentation
├── srcs/
│   ├── docker-compose.yml           # Service orchestration
│   ├── .env                         # Non-sensitive configuration
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── conf/my.cnf          # MariaDB configuration
│       │   └── tools/setup.sh       # Initialization script
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/www.conf        # PHP-FPM configuration
│       │   └── tools/setup.sh       # WordPress setup
│       └── nginx/
│           ├── Dockerfile
│           ├── conf/nginx.conf      # Nginx configuration
│           └── tools/               # SSL certificate generation
├── secrets/                         # Sensitive credentials (git-ignored)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── data/                           # Persistent volumes (git-ignored)
    ├── db/                         # MariaDB data files
    └── wordpress/                  # WordPress files
```

---

## Initial Setup from Scratch

### Step 1: Clone/Get the Project

```bash
cd /home/mbousset/Desktop
git clone <repo-url> inception
cd inception
```

### Step 2: Create Secret Files

All passwords are stored in the `secrets/` folder (one password per file):

```bash
# Create secrets directory if it doesn't exist
mkdir -p secrets

# Database passwords
echo "mbousset2001" > secrets/db_password.txt
echo "mbousset2001" > secrets/db_root_password.txt

# WordPress passwords
echo "mbousset2001" > secrets/wp_admin_password.txt
echo "userpass123" > secrets/wp_user_password.txt
```

> **Security:** Never commit the `secrets/` folder to Git. Add it to `.gitignore`.

### Step 3: Verify Configuration

Check the `.env` file contains non-sensitive configuration:

```bash
cat srcs/.env
```

Expected content:
```
DOMAIN_NAME=mbousset.42.fr
DB_NAME=mydatabase
DB_USER=42student
WP_ADMIN=mbousset
WP_ADMIN_EMAIL=mbousset@student.42.fr
WP_USER=mbaUser
WP_USER_EMAIL=mbauser@student.42.fr
```

### Step 4: Build and Start

```bash
# Build images and start services
make

# Or manually:
# make build   # Build Docker images
# make up      # Start containers
```

The first build may take 2-5 minutes. Monitor progress with:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

---

## Docker Compose Overview

The `srcs/docker-compose.yml` file orchestrates three services:

### Service: MariaDB

```yaml
mariadb:
  build: requirements/mariadb           # Build from custom Dockerfile
  image: mariadb:inception              # Tag the built image
  container_name: mariadb               # Fixed container name
  volumes:
    - db:/var/lib/mysql                 # Persistent database storage
  networks:
    - inception                         # Internal network
  env_file: .env                        # Load non-sensitive config
  secrets:                              # Mount Docker secrets
    - db_password
    - db_root_password
  restart: always                       # Auto-restart on failure
```

**Key Points:**
- Initializes on first run via `tools/setup.sh`
- Credentials sourced from `secrets/` files
- Database persists in `data/db/`
- Only accessible via Docker network (port 3306 not exposed)

### Service: WordPress

```yaml
wordpress:
  build: requirements/wordpress
  image: wordpress:inception
  container_name: wordpress
  volumes:
    - wordpress:/var/www/html
  networks:
    - inception
  depends_on:
    - mariadb                           # Wait for MariaDB before starting
  env_file: .env
  secrets:
    - db_password
    - wp_admin_password
    - wp_user_password
  restart: always
```

**Key Points:**
- Runs PHP-FPM only (no web server)
- Depends on MariaDB — waits for it to be ready
- Downloads and initializes WordPress via WP-CLI
- Shares filesystem with Nginx via `wordpress` volume

### Service: Nginx

```yaml
nginx:
  build: requirements/nginx
  image: nginx:inception
  container_name: nginx
  ports:
    - "443:443"                        # HTTPS only
  volumes:
    - wordpress:/var/www/html          # Read WordPress files
  networks:
    - inception
  depends_on:
    - wordpress                        # Wait for WordPress before starting
  restart: always
```

**Key Points:**
- Acts as reverse proxy to PHP-FPM
- Handles SSL/TLs with self-signed certificate
- Only service exposing ports to host
- All traffic goes through Nginx before reaching WordPress

### Custom Network

```yaml
networks:
  inception:
    name: inception
    driver: bridge
```

- Isolated Docker bridge network
- Services communicate by name (e.g., `mariadb:3306`)
- External traffic cannot reach internal services

### Volumes

```yaml
volumes:
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mbousset/data/wordpress
  db:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mbousset/data/db
```

- **Bind mounts** link containers to host filesystem
- Data persists even after container deletion
- Accessible directly on host for backups/inspection

### Secrets

```yaml
secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt
  wp_admin_password:
    file: ../secrets/wp_admin_password.txt
  wp_user_password:
    file: ../secrets/wp_user_password.txt
```

- Mounted as read-only files in `/run/secrets/`
- Scripts read with `cat /run/secrets/secretname`
- Never exposed in environment variables

---

## Dockerfile Breakdown

### MariaDB Dockerfile

```dockerfile
FROM alpine:3.22
RUN apk add --no-cache mariadb mariadb-client
COPY conf/my.cnf /etc/my.cnf
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh
EXPOSE 3306
ENTRYPOINT ["/setup.sh"]
```

**Key Points:**
- Alpine base: lightweight (~150MB)
- Custom `my.cnf` for configuration
- `setup.sh` handles initialization and runs MariaDB as PID 1
- Uses `ENTRYPOINT` — setup script always runs

### WordPress Dockerfile

```dockerfile
FROM alpine:3.22
RUN apk add --no-cache php82 php82-fpm php82-mysqli ... # 18 packages
RUN ln -s /usr/bin/php82 /usr/bin/php
RUN mkdir -p /var/www/html && chown -R nobody:nobody /var/www/html
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh
EXPOSE 9000
CMD ["/setup.sh"]
```

**Key Points:**
- 18 PHP extensions for WordPress compatibility
- PHP-FPM listens on port 9000 (not exposed, only to network)
- `setup.sh` downloads WordPress via WP-CLI and starts PHP-FPM
- Uses `CMD` — can be overridden (for debugging)

### Nginx Dockerfile

```dockerfile
FROM alpine:3.22
RUN apk add --no-cache nginx openssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=MA/ST=Benguerir/L=Benguerir/O=42/CN=localhost"
COPY conf/nginx.conf /etc/nginx/nginx.conf
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
```

**Key Points:**
- Generates self-signed SSL certificate at build time
- Custom `nginx.conf` as reverse proxy to PHP-FPM
- Runs Nginx in foreground (no daemon) as PID 1

---

## Setup Scripts

### MariaDB Setup (`srcs/requirements/mariadb/tools/setup.sh`)

```bash
#!/bin/sh

# Load passwords from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Create necessary directories and initialize database
mkdir -p /run/mysqld
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql ...
fi

# Bootstrap the database with initialization SQL
mysqld --user=mysql --bootstrap << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
EOF

# Start MariaDB as PID 1
exec mysqld --user=mysql
```

**Workflow:**
1. Reads passwords from `secrets/` files
2. Initializes database on first run (idempotent)
3. Creates database and users with appropriate privileges
4. Starts MariaDB in foreground

### WordPress Setup (`srcs/requirements/wordpress/tools/setup.sh`)

```bash
#!/bin/sh

# Load passwords from secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Download WP-CLI tool
wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Wait for MariaDB to be ready
until mysql -h mariadb -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# Install WordPress on first run
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp core download --allow-root
    wp config create --allow-root --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbhost=mariadb
    wp core install --allow-root --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASSWORD ...
    wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD ...
    wp theme install astra --activate --allow-root
fi

# Start PHP-FPM in foreground
exec php-fpm82 -F
```

**Workflow:**
1. Downloads WP-CLI (WordPress command-line tool)
2. Waits for MariaDB to accept connections (retry logic)
3. Downloads WordPress and configures database
4. Creates admin user and regular user
5. Installs and activates Astra theme
6. Starts PHP-FPM in foreground

---

## Makefile Commands

### `make` or `make all`
```bash
mkdir -p /home/mbousset/data/db
mkdir -p /home/mbousset/data/wordpress
docker compose -f srcs/docker-compose.yml up --build
```
Creates data directories, builds images, and starts services (blocking mode).

### `make build`
```bash
docker compose -f srcs/docker-compose.yml build
```
Only builds Docker images without starting containers.

### `make up`
```bash
docker compose -f srcs/docker-compose.yml up -d
```
Starts containers in background. **Requires `make build` to have been run first.**

### `make down`
```bash
docker compose -f srcs/docker-compose.yml down
```
Stops all containers gracefully. Preserves volumes and data.

### `make clean`
```bash
docker compose -f srcs/docker-compose.yml down --rmi all -v
```
Stops containers and removes images and volumes. Data directories retained.

### `make fclean`
```bash
make clean
sudo docker system prune -af
rm -rf /home/mbousset/data/db
rm -rf /home/mbousset/data/wordpress
```
Complete cleanup: removes everything including data directories.

### `make re`
```bash
make fclean
make all
```
Full rebuild from scratch.

---

## Container Management

### View Running Containers

```bash
docker ps
```

### View All Containers (including stopped)

```bash
docker ps -a
```

### View Container Logs

```bash
# Follow logs in real-time
docker logs -f mariadb
docker logs -f wordpress
docker logs -f nginx

# View last 50 lines
docker logs --tail 50 wordpress
```

### Execute Command in Running Container

```bash
# MariaDB shell
docker exec -it mariadb mysql -u root -p

# WordPress bash
docker exec -it wordpress sh

# Nginx configuration check
docker exec nginx nginx -t
```

### Container Inspection

```bash
# Detailed container info
docker inspect mariadb

# Network information
docker network inspect inception

# Volume information
docker volume inspect inception_db
docker volume inspect inception_wordpress
```

---

## Volume Management

### View Volumes

```bash
docker volume ls
```

### Inspect Volume Details

```bash
docker volume inspect inception_db
```

### Direct Host Access

Bind-mounted volumes are directly accessible on the host:

```bash
# WordPress files
ls -la /home/mbousset/data/wordpress/

# Database files
ls -la /home/mbousset/data/db/

# Backup WordPress
cp -r /home/mbousset/data/wordpress ~/backup_wordpress_$(date +%Y%m%d)

# Backup Database
cp -r /home/mbousset/data/db ~/backup_db_$(date +%Y%m%d)
```

### Restore from Backup

```bash
# Stop services
make down

# Restore data
rm -rf /home/mbousset/data/wordpress
cp -r ~/backup_wordpress_20260430 /home/mbousset/data/wordpress

# Restart
make up
```

---

## Environment Configuration

### Non-Sensitive Configuration (`.env`)

Located in `srcs/.env`:

```
DOMAIN_NAME=mbousset.42.fr
DB_NAME=mydatabase
DB_USER=42student
WP_ADMIN=mbousset
WP_ADMIN_EMAIL=mbousset@student.42.fr
WP_USER=mbaUser
WP_USER_EMAIL=mbauser@student.42.fr
```

**When to modify:**
- Changing domain name
- Changing database/user names
- Changing WordPress user names or emails

**Safe to commit to Git.**

### Sensitive Configuration (Secrets)

Located in `secrets/` folder:

```
secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```

**When to modify:**
- Changing any password
- Rotate credentials for security

**Never commit to Git. Add to `.gitignore`:**

```
# .gitignore
secrets/
data/
.env.local
```

---

## Configuration Files Explained

### Nginx Configuration (`srcs/requirements/nginx/conf/nginx.conf`)

Key responsibilities:
- Listens on port 443 (HTTPS)
- Routes requests to PHP-FPM at `wordpress:9000`
- Handles SSL/TLS with self-signed certificate
- Sets up reverse proxy headers

### PHP-FPM Configuration (`srcs/requirements/wordpress/conf/www.conf`)

Key settings:
- Listens on `0.0.0.0:9000` (accessible in Docker network)
- Runs under `nobody:nobody` user
- Process manager: dynamic with min/max workers
- Memory limit: 256MB

### MariaDB Configuration (`srcs/requirements/mariadb/conf/my.cnf`)

Key settings:
- Bind to all interfaces (`0.0.0.0`)
- Character set: utf8mb4
- Max connections and buffer adjustments
- Slow query logging (optional)

---

## Debugging & Troubleshooting

### Services Won't Start

**Check logs:**
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

**Common causes:**
- Port 443 already in use: `sudo lsof -i :443`
- Insufficient disk space: `df -h`
- Secrets files missing or unreadable
- Previous containers not cleaned: `make clean` then `make`

### Database Connection Issues

```bash
# Test from WordPress container
docker exec wordpress mysql -h mariadb -u 42student -p -e "SELECT 1;"

# Test from host
docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"
```

### WordPress Installation Incomplete

```bash
# Check if wp-config.php exists
docker exec wordpress ls -la /var/www/html/wp-config.php

# Reinitialize WordPress
docker exec wordpress rm -f /var/www/html/wp-config.php
docker restart wordpress
```

### Network Issues

```bash
# View network
docker network inspect inception

# Test connectivity
docker exec wordpress ping mariadb
docker exec mariadb ping wordpress
```

### Permission Denied on Data Directories

```bash
# Fix ownership
sudo chown -R $(whoami):$(whoami) /home/mbousset/data/
```

---

## Development Workflow

### Making Configuration Changes

1. **Update configuration file** (nginx.conf, my.cnf, www.conf)
2. **Rebuild images:**
   ```bash
   make clean
   make build
   ```
3. **Test changes:**
   ```bash
   make up
   docker logs -f <service-name>
   ```

### Modifying Passwords

1. **Update secret files:**
   ```bash
   echo "newpassword" > secrets/db_password.txt
   ```
2. **Rebuild everything:**
   ```bash
   make fclean
   make
   ```

### Adding WordPress Plugins/Themes

**Via WP-CLI inside container:**
```bash
docker exec wordpress wp plugin install akismet --activate --allow-root
docker exec wordpress wp theme install oceanwp --activate --allow-root
```

**Or via WordPress admin panel:**
Navigate to `https://mbousset.42.fr/wp-admin` and use the admin interface.

---

## Security Considerations

### Production Deployment

For production, replace/upgrade:

1. **Self-signed certificates** → Use Let's Encrypt or trusted CA
2. **Docker secrets** → Use Kubernetes secrets or cloud provider secrets management
3. **Alpine Linux** → Consider Ubuntu/Debian for broader package availability
4. **Default passwords** → Generate strong, random passwords
5. **Network access** → Implement firewall rules and rate limiting

### Development Best Practices

- Keep `secrets/` in `.gitignore`
- Don't log sensitive information
- Regularly update Alpine packages: `apk update && apk upgrade`
- Use read-only filesystems where possible
- Run containers as non-root users (WordPress uses `nobody`)

---

## Performance Optimization

### Database Optimization

```bash
# Check MariaDB status
docker exec mariadb mysql -u root -p -e "SHOW STATUS;"

# Optimize tables
docker exec mariadb mysql -u root -p mydatabase -e "OPTIMIZE TABLE wp_posts, wp_postmeta;"
```

### Caching (WordPress)

Consider installing caching plugins:
```bash
docker exec wordpress wp plugin install wp-super-cache --activate --allow-root
```

### Resource Limits

Edit `docker-compose.yml` to add CPU/memory limits:

```yaml
mariadb:
  # ... existing config ...
  deploy:
    resources:
      limits:
        cpus: '1'
        memory: 512M
      reservations:
        cpus: '0.5'
        memory: 256M
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [WordPress Administration](https://wordpress.org/support/article/administration-screens/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Alpine Linux Package Management](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management)

---

## Contact & Support

For questions or issues, contact the development team or refer to the project README.md.
