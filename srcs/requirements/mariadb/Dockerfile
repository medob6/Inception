FROM alpine:3.22

RUN apk add --no-cache \
    mariadb \
    mariadb-client

# We copy the my.cnf file to the container to configure the MariaDB server. This file can contain various settings such as the data directory, log file locations, and other configurations that are necessary for the proper functioning of the MariaDB server. By copying this file into the container, we ensure that the server is configured according to our requirements when it starts up. 
COPY conf/my.cnf /etc/my.cnf
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh
EXPOSE 3306
ENTRYPOINT ["/setup.sh"]