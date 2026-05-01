FROM alpine:3.22

RUN apk update && apk add --no-cache \
    wget \
    php \
    php-cli \
    php-mysqli \
    php-session \
    php-pdo

COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh

CMD ["/script.sh"]