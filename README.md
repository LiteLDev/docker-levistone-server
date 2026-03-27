# docker-levistone-server

English | [简体中文](README.zh.md)

## Installation

To start the server in a Linux container, run the following command:

```sh
docker run -d -it -e EULA=TRUE -p 19132:19132/udp -v levistone-server-data:/data ghcr.io/liteldev/levistone-server:latest-wine
```

Or, if you want to use a Windows container, run the following command:

```sh
docker run -d -it -e EULA=TRUE -p 19132:19132/udp -v levistone-server-data:C:\data ghcr.io/liteldev/levistone-server:latest-windows
```

### Environment variables

- `PYPI_MIRROR_URL`: Url of Pypi mirror site

- `LEVISTONE_VERSION`: Version of LeviStone which will be installed

For more environment variables, please refer to: https://lamina.levimc.org/user_guides/install_on_docker/#environment-variables
