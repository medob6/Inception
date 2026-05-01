# USER_DOC.md — User Documentation

## Overview

This project provides a complete WordPress infrastructure stack using Docker. It consists of three main services running in isolated containers:

- **Nginx** — Web server with SSL/TLS encryption (HTTPS)
- **WordPress + PHP-FPM** — Content management system and application server
- **MariaDB** — Database backend for storing WordPress data

All services communicate securely through a private Docker network. Only the web server (Nginx) is exposed to your browser on port 443.

---

## Starting the Project

### Prerequisites

- Docker and Docker Compose installed on your system
- Linux/Mac/WSL environment
- At least 2GB of available disk space

### Quick Start

From the project root directory, run:

```bash
make
```

This command will:
1. Create required data directories
2. Build Docker images from custom Dockerfiles
3. Start all three services
4. Initialize the database and WordPress installation

The first startup may take 1-2 minutes as Docker downloads Alpine Linux and installs dependencies.

---

## Stopping the Project

To stop all running services gracefully:

```bash
make down
```

This stops the containers but preserves all your WordPress data and database.

---

## All Available Commands

| Command | Purpose |
|---------|---------|
| `make` or `make all` | Build and start the entire stack |
| `make build` | Build Docker images without starting containers |
| `make up` | Start containers (must run `make build` first) |
| `make down` | Stop all containers |
| `make clean` | Stop containers and remove images and volumes |
| `make fclean` | Full cleanup: remove everything including data directories |
| `make re` | Complete rebuild (fclean + all) |

---

## Accessing the Website

### WordPress Frontend

Open your browser and navigate to:

```
https://mbousset.42.fr
```

> **Note:** Your browser may show a security warning because the SSL certificate is self-signed. Click "Advanced" or "Proceed" to continue.

The WordPress homepage will display with the Astra theme pre-installed.

### WordPress Admin Panel

Access the admin dashboard at:

```
https://mbousset.42.fr/wp-login.php
```

#### Admin Credentials

| Field | Value |
|-------|-------|
| **Username** | `mbousset` |
| **Password** | Located in `/secrets/wp_admin_password.txt` |
| **Email** | mbousset@student.42.fr |

#### Regular User Credentials

| Field | Value |
|-------|-------|
| **Username** | `mbaUser` |
| **Password** | Located in `/secrets/wp_user_password.txt` |
| **Email** | mbauser@student.42.fr |

---

## Credentials & Secrets Management

All sensitive credentials are stored in the `secrets/` folder at the project root:

```
secrets/
├── db_password.txt           # Database user password
├── db_root_password.txt      # Database root password
├── wp_admin_password.txt     # WordPress admin password
└── wp_user_password.txt      # WordPress regular user password
```

### Viewing Credentials

To view any password, open the corresponding file in the `secrets/` folder. For example:

```bash
cat secrets/db_password.txt
```

### Changing Credentials

To change credentials, you must:

1. **Stop the project:**
   ```bash
   make down
   ```

2. **Update the secret files** in the `secrets/` folder with new values

3. **Clean and rebuild:**
   ```bash
   make fclean
   make
   ```

> **Important:** Changing credentials requires a full rebuild because they are embedded during container initialization.

---

## Configuration

### Domain Name

The project is configured for:

- **Domain:** `mbousset.42.fr`
- **Protocol:** HTTPS (SSL/TLS encrypted)

To use a different domain, contact a developer to update the configuration.

### Database

| Setting | Value |
|---------|-------|
| **Database Name** | `mydatabase` |
| **Database User** | `42student` |
| **Host** | Internal (not accessible from outside) |
| **Port** | 3306 (internal only) |

---

## Checking Service Status

### Using Docker Commands

To see running containers:

```bash
docker ps
```

You should see three containers:
- `mariadb`
- `wordpress`
- `nginx`

### Detailed Service Status

```bash
docker compose -f srcs/docker-compose.yml ps
```

### View Container Logs

To debug issues, view logs for a specific service:

```bash
# MariaDB logs
docker logs mariadb

# WordPress logs
docker logs wordpress

# Nginx logs
docker logs nginx
```

### Check if Services Are Responding

Verify HTTPS access works:

```bash
curl -k https://mbousset.42.fr
```

The `-k` flag ignores the self-signed certificate warning.

---

## Common Issues & Troubleshooting

### Website shows "Connection refused"

**Solution:** Wait 30-60 seconds for all services to fully initialize. Check logs:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### WordPress shows database error

**Solution:** MariaDB may not have started before WordPress. Restart all services:
```bash
make down
make up
```

### Cannot access WordPress admin panel

**Solution:** Clear your browser cache and cookies for the domain, then try again in a private/incognito window.

### Services crash immediately

**Solution:** Check if port 443 is already in use:
```bash
sudo lsof -i :443
```

If in use, stop the conflicting service or run on a different machine.

### SSL Certificate Warning

This is normal. The certificate is self-signed for development purposes. Click "Advanced" → "Proceed" in your browser.

---

## Data Persistence

Your WordPress files and database are stored on your host machine, not inside containers:

- **WordPress files:** `/home/mbousset/data/wordpress/`
- **Database files:** `/home/mbousset/data/db/`

These directories are created automatically and survive container restarts. They are only deleted when you run `make fclean`.

---

## Security Notes

- **Passwords are stored locally** in the `secrets/` folder (not in `.env`)
- **Credentials are sensitive** — Keep `secrets/` folder private and secure
- **Self-signed SSL certificate** — Used for development; replace with a real certificate for production
- **Database is isolated** — Not accessible from outside the Docker network
- **Only Nginx exposes ports** — Other services are internal only

---

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review service logs with `docker logs <service-name>`
3. Ensure Docker and Docker Compose are installed and updated
4. Verify your system has sufficient disk space
5. Contact the development team for technical issues
