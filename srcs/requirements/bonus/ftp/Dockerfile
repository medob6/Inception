FROM alpine:3.22

RUN apk add --no-cache vsftpd shadow

# create directory for vsftpd configuration
RUN mkdir -p /etc/vsftpd

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 21
EXPOSE 30000-30009

CMD ["/setup.sh"]
