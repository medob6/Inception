FROM alpine:3.22

RUN apk add --no-cache redis && echo "maxmemory 256mb" >> /etc/redis.conf

RUN echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf
RUN sed -i -E 's/^bind\s+.*/#&/' /etc/redis.conf || true
RUN sed -i -E 's/^protected-mode\s+.*/protected-mode no/' /etc/redis.conf || echo "protected-mode no" >> /etc/redis.conf

# Start redis with the custom config file
CMD ["redis-server", "/etc/redis.conf"]