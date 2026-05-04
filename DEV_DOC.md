*Developer Documentation*

# Environment Setup

## Prerequisites

- Docker
- Docker Compose
- Make

## Configuration files

- Service configs live under [srcs/requirements/](srcs/requirements/)
- The main Compose file is [srcs/docker-compose.yml](srcs/docker-compose.yml)

## Secrets

- Secrets are stored in [secrets/](secrets/)
- Each secret file contains a single value
- Update secrets before the first build or when rotating credentials

# Build and Launch

## Build and start

```bash
make
```

## Common targets

```bash
make up
make down
make re
```

# Container and Volume Management

## Container lifecycle

```bash
docker ps
docker stop <container>
docker start <container>
docker restart <container>
```

## Inspect logs

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

## Volumes

```bash
docker volume ls
docker volume inspect <volume>
docker volume rm <volume>
```

# Data Persistence

- Persistent data is stored in Docker named volumes defined in [srcs/docker-compose.yml](srcs/docker-compose.yml)
- MariaDB data and WordPress uploads/themes/plugins survive container rebuilds
- To reset all data, remove the volumes and rebuild the stack

```bash
make down
docker volume rm <volume>
make up
```
