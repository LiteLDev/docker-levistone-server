FROM ghcr.io/liteldev/levilamina-server:latest-wine

# LeviStone runs Endstone plugins, which are Python, so the server needs the Windows Python in
# the Wine prefix of lip. The entrypoint installs it there with lip's Wine on the first start.
ARG PYTHON_VERSION=3.14.10
ADD https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe /opt/python-installer.exe

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
