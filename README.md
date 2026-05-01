*This project has been created as part of the 42 curriculum by mbousset.*

# Inception

## Description

The goal of this project is to broaden knowledge of system administration by using Docker. It involves setting up a small infrastructure composed of different services (Nginx, WordPress, MariaDB) using Docker Compose, ensuring each service runs in its own dedicated, isolated container.

The project teaches containerization best practices, networking, data persistence, security considerations, and automation through Infrastructure-as-Code principles. By the end of this project, you will understand how modern microservices architectures work and how to orchestrate multiple services efficiently.

---

## Project Description

### Use of Docker & Sources Included

Docker is used to build isolated environments from scratch without relying on pre-configured DockerHub images (like the official `nginx` or `wordpress` images). Each Dockerfile is custom-built to satisfy project requirements.

**Base Operating System:** Alpine Linux 3.20 is used as the base for all Dockerfiles, as mandated by the project requirements. Alpine is lightweight (~5MB) and suitable for containerized applications.

**Services Architecture:**
- **Nginx (Alpine 3.20):** Web server with SSL/TLS support, acting as a reverse proxy
- **WordPress + PHP-FPM (Alpine 3.20):** Application server with necessary PHP extensions
- **MariaDB (Alpine 3.20):** Relational database for WordPress
- **Custom Bridge Network:** Enables secure inter-container communication
- **Docker Volumes:** Ensures data persistence across container restarts

### Main Design Choices

* **One service per container:** Each component (Nginx, WordPress/PHP-FPM, MariaDB) runs independently, following the single responsibility principle and making the infrastructure modular and maintainable.

* **Custom bridge network (`inception`):** Allows internal communication between Nginx, WordPress, and MariaDB using service names for DNS resolution without exposing the database to the host machine.

* **Persistent Docker volumes with bind mounts:** Database files and WordPress content are stored on the host at `/home/mbousset/data/db` and `/home/mbousset/data/wordpress`, ensuring data survives container lifecycle changes.

* **Makefile automation:** Simplifies building, running, and cleaning operations. Common tasks are abstracted into simple commands (`make`, `make up`, `make down`, `make clean`, `make fclean`).

* **Service dependency management:** Docker Compose ensures correct startup order: MariaDB → WordPress → Nginx, with health checks preventing premature startup of dependent services.

* **SSL/TLS encryption:** Nginx uses self-signed certificates generated at image build time, enabling HTTPS-only access.

* **Environment-driven configuration:** Sensitive data (passwords, usernames) are managed via a `.env` file, keeping credentials out of images and version control.

### Technical Comparisons

#### Virtual Machines vs. Docker

**Virtual Machines:**
- Virtualize the entire physical hardware stack
- Each VM requires a complete guest operating system (dozens of GB)
- Heavy resource consumption (CPU, RAM, disk)
- Slower startup times (minutes)
- Full isolation but at the cost of inefficiency

**Docker:**
- Virtualizes only the operating system kernel
- Multiple lightweight containers share the host's OS (MB-level images)
- Minimal resource overhead; containers start in seconds
- Maintained kernel compatibility with the host
- Rapid scaling and density; ideal for microservices

**Use in this project:** Docker allows running Nginx, WordPress, and MariaDB on the same host machine with minimal resource usage, while maintaining complete isolation between services.

#### Secrets vs. Environment Variables

**Environment Variables:**
- Stored in plain text in dockerfiles, docker-compose.yml, or .env files
- Easily exposed through container inspection (`docker inspect`)
- Visible in process listings
- Simple to use but inherently insecure for sensitive data

**Docker Secrets:**
- Encrypted at rest and in transit
- Mounted into containers as temporary files in `/run/secrets/`
- Only accessible to authorized containers
- Ideal for production environments with sensitive credentials
- Requires Docker Swarm or Kubernetes

**Use in this project:** Environment variables are used for configuration flexibility (database names, WordPress settings) while the project acknowledges that production deployments should migrate to Docker Secrets. Credential files are stored in `.gitignore` to prevent accidental commits.

#### Docker Network vs. Host Network

**Docker Network (Custom Bridge):**
- Creates an isolated virtual network with internal DNS
- Containers communicate using service names (e.g., `mariadb:3306`)
- External traffic cannot reach internal services without explicit port mapping
- Multiple networks can coexist without interference
- Default security model for containerized applications

**Host Network:**
- Container shares the host's network namespace
- Containers access services via `localhost` or host IP
- Removes network isolation; all container ports are exposed
- Can cause port conflicts if multiple containers use the same ports
- Slight performance improvement but at the cost of security

**Use in this project:** A custom bridge network named `inception` is created to allow Nginx, WordPress, and MariaDB to communicate securely via service names. Only Nginx exposes port 443 to the host; the database remains completely isolated.

#### Docker Volumes vs. Bind Mounts

**Bind Mounts:**
- Direct mapping of host filesystem paths into containers
- Container sees the exact directory structure from the host
- Host has full filesystem control
- Tied to specific host machine paths (portability issues)
- Permissions must match between host and container

**Docker Volumes:**
- Managed entirely by the Docker daemon
- Stored in Docker's data directory (`/var/lib/docker/volumes/`)
- Decoupled from host filesystem structure
- Easier to backup, migrate, and manage
- Better isolation and security
- Recommended best practice for production data

**Hybrid approach in this project:** The project uses Docker Volumes with bind mount drivers (`type: none, o: bind`), combining the benefits of both:
- Volumes are managed by Docker (easier lifecycle management)
- Bind mount driver allows specifying host paths for direct access
- Data remains accessible on the host for backups and inspection

---

## Instructions

### Prerequisites

- Docker (version 20.10 or later)
- Docker Compose (version 1.29 or later)
- Make
- A text editor for `.env` configuration
- Linux or macOS with sudo access for `/etc/hosts` modification

### Setup

#### 1. Environment Configuration

Create a `.env` file in the `srcs/` directory with your configuration:

```bash
cd srcs/
nano .env
```

Add the following variables:

```env
# MariaDB Configuration
MARIADB_ROOT_PASSWORD=your_secure_root_password
MARIADB_DATABASE=wordpress
MARIADB_USER=wordpress_user
MARIADB_PASSWORD=your_secure_wp_password

# WordPress Configuration
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wordpress_user
WORDPRESS_DB_PASSWORD=your_secure_wp_password
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=your_secure_admin_password
WORDPRESS_ADMIN_EMAIL=admin@example.com
WORDPRESS_TITLE=My Awesome Site
WORDPRESS_URL=https://mbousset.42.fr
```

#### 2. Host Domain Configuration

Edit `/etc/hosts` to map your domain to localhost:

```bash
sudo nano /etc/hosts
```

Add this line:

```
127.0.0.1   mbousset.42.fr
```

Save and exit (Ctrl+X, then Y, then Enter).

### Execution

#### Build and Start Services (Recommended)

From the project root:

```bash
make
```

This command:
- Creates necessary data directories on the host
- Builds Docker images for all services
- Starts all containers in foreground mode

#### Other Make Commands

```bash
# Build images without running
make build

# Start services in background (after images are built)
make up

# Stop all running services
make down

# Remove containers and images (keep volumes)
make clean

# Full cleanup (remove containers, images, and volumes)
make fclean

# Rebuild everything from scratch
make re
```

### Accessing the Services

Once all services are running:

- **WordPress:** Open your browser and visit `https://mbousset.42.fr`
  - Accept the SSL warning (self-signed certificate)
  - Login with admin credentials from `.env`

- **Database (MariaDB):** Only accessible from within the container network
  - From host: `docker exec -it dbcontainer_name mariadb -u root -p`

### Verification

Check that all services are running:

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs for a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

---

## Resources

### Official Documentation

- [Docker Documentation](https://docs.docker.com/) - Comprehensive Docker guide and API reference
- [Docker Compose Documentation](https://docs.docker.com/compose/) - Multi-container Docker applications
- [Alpine Linux Official](https://www.alpinelinux.org/) - Lightweight Linux distribution
- [Nginx Documentation](https://nginx.org/en/docs/) - Web server and reverse proxy configuration
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php) - FastCGI Process Manager
- [MariaDB Official Documentation](https://mariadb.com/docs/) - Database administration and configuration
- [WordPress Developer Documentation](https://developer.wordpress.org/) - WordPress API and customization

### Tutorials & Articles

- [Docker Networking Overview](https://docs.docker.com/network/) - Understanding Docker networks
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/) - Writing efficient Dockerfiles
- [Alpine Linux Package Management](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management) - Using apk for Alpine
- [SSL/TLS Certificates with OpenSSL](https://www.openssl.org/docs/) - Certificate generation and management
- [Docker Volumes Best Practices](https://docs.docker.com/storage/volumes/) - Persistent storage strategies

### Related Concepts

- Microservices Architecture
- Infrastructure-as-Code (IaC)
- Containerization and Container Orchestration
- DevOps Best Practices
- Security in Containerized Environments

---

## AI Usage

AI (Claude) was utilized for the following aspects of this project:

### Tasks and Parts Where AI Was Used

1. **README.md Creation and Structure**
   - Generating comprehensive documentation structure
   - Creating detailed technical comparisons and explanations
   - Organizing content for clarity and accessibility

2. **Docker Configuration Assistance**
   - Verifying Dockerfile syntax and best practices
   - Optimizing Alpine Linux package installations
   - Ensuring proper service dependency declarations

3. **Debugging and Troubleshooting**
   - Analyzing error messages from container logs
   - Suggesting fixes for network connectivity issues
   - Recommending permission and volume mounting solutions

4. **Configuration Templates**
   - Creating example `.env` files with proper variable names
   - Generating nginx.conf proxy pass configurations
   - Providing PHP-FPM and MariaDB configuration templates

5. **Documentation and Comments**
   - Adding clarifying comments to Dockerfiles
   - Explaining complex Docker Compose directives
   - Creating helpful command references in the Makefile

6. **Best Practices and Design Decisions**
   - Recommending Docker network architecture patterns
   - Advising on volume vs. bind mount trade-offs
   - Suggesting security considerations and hardening steps

### Limitations and Human Decisions

- All Dockerfiles and configuration files were written and tested by the project author
- Design decisions (Alpine Linux choice, port selections, directory structure) were project requirements
- Manual testing and verification of service connectivity and SSL certificates
- Actual WordPress installation and setup scripts were manually implemented

---

## Troubleshooting

### Container Won't Start

```bash
# View detailed logs for a service
docker compose -f srcs/docker-compose.yml logs -f mariadb

# Check container status
docker compose -f srcs/docker-compose.yml ps
```

### Port 443 Already in Use

```bash
# Find what's using the port
sudo lsof -i :443

# Modify srcs/docker-compose.yml port mapping if needed
# Or stop the conflicting service
```

### Database Connection Errors

- Verify `.env` is in `srcs/` directory and readable
- Check that service names match in configurations (use `mariadb` as hostname, not IP)
- Ensure MariaDB container is fully initialized before WordPress starts
- View MariaDB logs: `docker compose -f srcs/docker-compose.yml logs mariadb`

### WordPress Installation Issues

- Confirm SSL certificate warning page appears (certificate is self-signed)
- Check PHP-FPM logs for errors: `docker compose -f srcs/docker-compose.yml logs wordpress`
- Verify WordPress files were written to `/home/mbousset/data/wordpress`
- Ensure proper file permissions: `sudo chown -R $(whoami) /home/mbousset/data`

### SSL Certificate Warnings

This is expected with self-signed certificates. The browser will show:
- "NET::ERR_CERT_AUTHORITY_INVALID" (Chrome)
- "HSTS" or certificate warnings (Firefox)

This is normal for development environments. In production, use certificates from Let's Encrypt or other trusted CAs.

### Volumes Not Persisting

```bash
# Verify volume mounts in running container
docker inspect container_name | grep Mounts

# Check data directory on host
ls -la /home/mbousset/data/

# Ensure proper permissions
sudo chown -R $(whoami):$(whoami) /home/mbousset/data
```

---

## Project Structure

```
inception/
├── Makefile                    # Automation for building, running, and cleaning
├── README.md                   # This documentation
├── secrets/                    # Sensitive credentials (add to .gitignore)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                    # Environment variables (create this)
    ├── docker-compose.yml      # Service orchestration configuration
    └── requirements/
        ├── nginx/              # Web server container
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf  # Nginx configuration with SSL setup
        │   └── tools/
        ├── wordpress/          # WordPress + PHP-FPM container
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf    # PHP-FPM configuration
        │   └── tools/
        │       └── setup.sh    # WordPress initialization script
        ├── mariadb/            # Database container
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── my.cnf      # MariaDB configuration
        │   └── tools/
        │       └── setup.sh    # Database initialization script
        └── bonus/              # Additional optional requirements
```

---

## Next Steps

- [ ] Implement bonus requirements (additional services, logging, monitoring)
- [ ] Add health checks for all services
- [ ] Set up automated backups of database and WordPress files
- [ ] Configure logging and monitoring solutions
- [ ] Performance optimization and benchmarking
- [ ] Security hardening and penetration testing
- [ ] Documentation of advanced features and customization options
