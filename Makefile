COMPOSE_FILE = srcs/docker-compose.yml

all:
	mkdir -p /home/mbousset/data/db
	mkdir -p /home/mbousset/data/wordpress
	docker compose -f $(COMPOSE_FILE) up --build

build:
	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all -v

fclean:
	sudo docker system prune -af

re: fclean all

.PHONY: all build up down clean fclean re
