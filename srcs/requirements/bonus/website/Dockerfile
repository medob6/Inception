FROM alpine:3.22

RUN apk add --no-cache nodejs npm

WORKDIR /home/app
COPY tools/ /home/app/

RUN npm init -y && npm install express -y

EXPOSE 3000

CMD ["node", "server.js"]
