# docker-levistone-server

[English](README.md) | 简体中文

## 安装

要在 Linux 容器中启动服务器，请运行第一条命令；如果您的服务器在中国大陆，请运行第二条命令以更快快速地安装：

```sh
docker run -d -it -e EULA=TRUE -p 19132:19132/udp -v levistone-server-data:/data ghcr.io/liteldev/levistone-server:latest-wine
```

```sh
docker run -d -it -e EULA=TRUE -e GO_MODULE_PROXY_URL=https://goproxy.cn -e GITHUB_MIRROR_URL=https://github.bibk.top -e PYPI_MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple -p 19132:19132/udp -v levistone-server-data:/data ghcr.nju.edu.cn/liteldev/levistone-server:latest-wine
```

或者，如果您想使用 Windows 容器，请运行第一条命令；如果您的服务器在中国大陆，请运行第二条命令以更快快速地安装：

```sh
docker run -d -it -e EULA=TRUE -p 19132:19132/udp -v levistone-server-data:C:\data ghcr.io/liteldev/levistone-server:latest-windows
```

```sh
docker run -d -it -e EULA=TRUE -e GO_MODULE_PROXY_URL=https://goproxy.cn -e GITHUB_MIRROR_URL=https://github.bibk.top -e PYPI_MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple -p 19132:19132/udp -v levistone-server-data:C:\data ghcr.nju.edu.cn/liteldev/levistone-server:latest-windows
```

### 环境变量

- `PYPI_MIRROR_URL`: Pypi镜像站URL

- `LEVISTONE_VERSION`: 要安装的LeviStone版本

更多环境变量请参考: https://lamina.levimc.org/zh/user_guides/install_on_docker/#环境变量
