*User Documentation*

# Overview

This stack provides a small web platform built with containers. It includes:

- Nginx as the public web server and TLS termination
- WordPress as the website and admin interface
- MariaDB as the database
- Optional bonus services like Redis, Adminer, FTP, cAdvisor, and a static website

# Start and Stop

## Start

```bash
make up
```

## Stop

```bash
make down
```

## Restart

```bash
make re
```

# Access the Website and Admin Panel

- Website: https://mbousset.42.fr
- WordPress admin: https://mbousset.42.fr/wp-admin

# Credentials

Credentials are stored as Docker secrets in the [secrets/](secrets/) directory. Each file contains a single value, for example:

- Database passwords
- WordPress admin and user passwords
- FTP password (if enabled)

To change a credential, edit the corresponding file in [secrets/](secrets/) and rebuild the stack:

```bash
make down
make up
```

# Check Services

## Check containers

```bash
docker ps
```

## Check logs

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

## Verify health

- Open the website in a browser
- Log in to the WordPress admin panel
- Confirm database connectivity by visiting the site and checking WordPress settings
