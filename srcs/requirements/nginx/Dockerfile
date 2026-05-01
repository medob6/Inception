FROM alpine:3.22

# installing nginx and openssl in alpine image
RUN apk add --no-cache nginx openssl

# key and cert creation for ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=MA/ST=Benguerir/L=Benguerir/O=42/CN=localhost"

# here u can copy multiple config files and maybe chose wich one to run at runing of the container , or in docker compoe file u can specify wich one to run
# but watever is in the command will run 
COPY conf/nginx.conf /etc/nginx/nginx.conf

# expose document which port nginx will listen to , it doesn't actually publish the port but it serves as documentation and also can be used by docker to automatically publish the port when running the container with -P flag
# or by using docker compose file to specify the port mapping
# and we can specify multiple ports if we want to listen to both http and https
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
