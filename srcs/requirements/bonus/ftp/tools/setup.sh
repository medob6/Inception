#!/bin/sh
set -e

# FTP settings
FTP_USER="${FTP_USER:-ftpuser}"

FTP_PASS="$(cat /run/secrets/ftp_password)"

FTP_HOME="/home/${FTP_USER}/www"

# create ftp user if not exists
if ! id -u "${FTP_USER}" >/dev/null 2>&1; then
    adduser -D -h "/home/${FTP_USER}" -s /sbin/nologin "${FTP_USER}"
fi

# set password
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# prepare web root and ensure ownership (wordpress volume is mounted here)
mkdir -p "${FTP_HOME}"
chown ${FTP_USER}:${FTP_USER} /home/${FTP_USER}

# We avoid recursively chowning the mounted WordPress volume (FTP_HOME) 
# to prevent breaking PHP-FPM (which relies on nobody:nobody ownership).

# start vsftpd in foreground using the provided config
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
