FROM alpine:3.22

RUN apk add --no-cache wget libc6-compat

# Download the official pre-compiled cAdvisor binary and make it executable
RUN wget -O /usr/bin/cadvisor https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 \
    && chmod +x /usr/bin/cadvisor

EXPOSE 8080

CMD ["/usr/bin/cadvisor", "-logtostderr"]