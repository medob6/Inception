COMPOSE_FILE = srcs/docker-compose.yml

all:
	mkdir -p /home/mbousset/data/db
	mkdir -p /home/mbousset/data/wordpress
	docker compose -f $(COMPOSE_FILE) up --build

build:
	docker compose -f $(COMPOSE_FILE) build

#make sure to run make build before make up, otherwise the images won't be built and the containers won't start
up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all -v

fclean:clean
	sudo docker system prune -af
	rm -rf /home/mbousset/data/db
	rm -rf /home/mbousset/data/wordpress

re: fclean all

.PHONY: all build up down clean fclean re
