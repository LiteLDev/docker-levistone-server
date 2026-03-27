FROM ghcr.io/liteldev/levilamina-server:latest-windows

COPY entrypoint.cmd /Windows/entrypoint.cmd

ADD https://www.python.org/ftp/python/3.13.12/python-3.13.12-amd64.exe python-installer.exe

RUN python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 && del python-installer.exe

ENTRYPOINT ["entrypoint.cmd"]
