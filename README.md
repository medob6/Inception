*This project has been created as part of the 42 curriculum by mbousset.*

# Description

This project builds a small, production-like web stack using Docker Compose. The goal is to orchestrate multiple services (web server, database, CMS, and optional bonus tools) with isolated networking, persistent storage, and secure secrets handling.

The stack includes:
- Nginx as the reverse proxy and TLS termination
- WordPress with PHP-FPM
- MariaDB as the database
- Bonus services under srcs/requirements/bonus (e.g., Redis, Adminer, FTP, cAdvisor, and a static website)

# Instructions

## Prerequisites

- Docker and Docker Compose
- Make

## Build and run

```bash
make
```

## Common targets

```bash
make up
make down
make re  (with sudo)
make clean
```

## Notes

- Secrets are stored in the secrets/ directory and mounted into containers.
- Configuration files live under srcs/requirements/*/conf and scripts under srcs/requirements/*/tools.

# Project Description (Docker and Sources)

This project uses Docker to package each service with its runtime, configuration, and setup scripts, enabling reproducible builds and isolated environments. The main sources included are:

- Dockerfiles and setup scripts for each service
- Nginx, MariaDB, WordPress, and bonus service configurations
- A minimal static website used as a bonus service

## Main design choices

- One container per service with a dedicated Dockerfile
- A private Docker network for service-to-service communication
- Named volumes for data persistence (database and WordPress files)
- Secrets injected via Docker secrets rather than environment variables

## Comparisons

### Virtual Machines vs Docker

- Virtual Machines provide full OS isolation but are heavier and slower to start.
- Docker uses OS-level isolation (namespaces/cgroups), making containers lightweight and fast to build/run.

### Secrets vs Environment Variables

- Secrets are stored outside the image, mounted at runtime, and not visible in process listings.
- Environment variables are easy to use but can be leaked via logs, process dumps, or shell history.

### Docker Network vs Host Network

- Docker networks isolate services, allow DNS-based discovery, and reduce host exposure.
- Host networking removes isolation and can cause port conflicts while simplifying debugging.

### Docker Volumes vs Bind Mounts

- Volumes are managed by Docker, portable, and ideal for persistent data.
- Bind mounts map host paths directly, which is useful for local development but less portable.

# Resources

- Docker Docs: https://docs.docker.com/
- Docker Compose Docs: https://docs.docker.com/compose/
- Nginx Docs: https://nginx.org/en/docs/
- MariaDB Docs: https://mariadb.com/kb/en/documentation/
- WordPress Docs: https://developer.wordpress.org/

## AI usage

AI was used to draft the README structure and ensure the required sections and comparisons were included and for understanding the project requirements with minimal assistance. No code, configuration, or scripts were generated or modified by AI.
