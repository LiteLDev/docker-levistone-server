FROM ghcr.io/liteldev/levilamina-server:latest-wine

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ADD https://www.python.org/ftp/python/3.15.2/python-3.15.2-amd64.exe /opt/python-installer.exe

ENTRYPOINT ["entrypoint.sh"]
