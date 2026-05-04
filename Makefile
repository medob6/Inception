COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/mbousset/data
DB_DIR = $(DATA_DIR)/db
WP_DIR = $(DATA_DIR)/wordpress

all:
	mkdir -p $(DB_DIR)
	mkdir -p $(WP_DIR)
	docker compose -f $(COMPOSE_FILE) up --build

build:
	docker compose -f $(COMPOSE_FILE) build

up: build
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

restart:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make restart SERVICE=<service>"; \
		exit 1; \
	fi
	docker compose -f $(COMPOSE_FILE) restart $(SERVICE)

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all -v

reset-volumes:
	docker compose -f $(COMPOSE_FILE) down -v
	rm -rf $(DB_DIR)
	rm -rf $(WP_DIR)

fclean:clean
	sudo docker system prune -af
	rm -rf $(DB_DIR)
	rm -rf $(WP_DIR)

re: fclean all

help:
	@echo "Targets: all build up down clean fclean re logs reset-volumes restart"

.PHONY: all build up down clean fclean re logs reset-volumes restart help
