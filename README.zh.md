# docker-levistone-server

[English](README.md) | 简体中文

带 [LeviLamina](https://github.com/LiteLDev/LeviLamina) 和 [LeviStone](https://github.com/LiteLDev/LeviStone) 的基岩版专用服务器 Docker 镜像。LeviStone 用来运行 Python 编写的 Endstone 插件。镜像基于 [docker-levilamina-server](https://github.com/LiteLDev/docker-levilamina-server) 的镜像，额外加入 Python 和 LeviStone。

| 镜像 | 运行于 |
| --- | --- |
| `ghcr.io/liteldev/levistone-server:latest-wine` | Linux 容器：`lip` 原生运行，并用它自行安装的 Wine 运行 Windows 版服务器 |
| `ghcr.io/liteldev/levistone-server:latest-windows` | Windows 容器 |

## 安装

在 Linux 容器中启动服务器：

```sh
docker run -d -it --name levistone -e EULA=TRUE -p 19132:19132/udp -p 19132:19132/tcp -v levistone-server-data:/data ghcr.io/liteldev/levistone-server:latest-wine
```

如果服务器在中国大陆，可以使用镜像站加速：

```sh
docker run -d -it --name levistone -e EULA=TRUE -e GITHUB_MIRROR_URL=https://v4.gh-proxy.org/https://github.com/ -e PYPI_MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple -p 19132:19132/udp -p 19132:19132/tcp -v levistone-server-data:/data ghcr.nju.edu.cn/liteldev/levistone-server:latest-wine
```

或者在 Windows 容器中启动：

```pwsh
docker run -d -it --name levistone -e EULA=TRUE -p 19132:19132/udp -p 19132:19132/tcp -v levistone-server-data:C:\data ghcr.io/liteldev/levistone-server:latest-windows
```

首次启动时，容器会在卷中搭建服务器：`lip` 先安装它的 Wine 和 Visual C++ 运行库（Wine 镜像），再安装游戏、LeviLamina 和 `PACKAGES` 中的包；然后容器把 Python 装进 Wine 前缀（Wine 镜像），并用 pip 把 LeviStone 装到 `mods/EndstoneRuntime`。这需要几分钟，之后的启动只需几秒。Endstone 插件放在卷中的 `plugins/` 目录。

用 `docker stop -t 60 levistone` 停止服务器：`lip` 会向服务器输入 `stop`，服务器保存世界后退出。Compose 文件（[wine/compose.yaml](wine/compose.yaml)、[windows/compose.yaml](windows/compose.yaml)）同样给出一分钟（`stop_grace_period`）。

### 环境变量

| 变量 | 默认值 | 含义 |
| --- | --- | --- |
| `EULA` | | 必须为 `TRUE`，表示你接受 [Minecraft 最终用户许可协议](https://www.minecraft.net/eula)。 |
| `VERSION` | `LATEST` | 要安装的 LeviLamina 版本，如 `26.60.7`。游戏版本随之确定。 |
| `LEVISTONE_VERSION` | 最新版 | 要安装的 LeviStone 版本，如 `0.11.15.post1`（[版本列表](https://pypi.org/project/levistone/#history)）。必须与 LeviLamina 版本相匹配。 |
| `PACKAGES` | | 首次启动时额外安装的 `lip` 包，以空格分隔。 |
| `GITHUB_MIRROR_URL` | | `lip` 下载用的 GitHub 镜像站。 |
| `PYPI_MIRROR_URL` | | pip 使用的 PyPI 镜像站，如 `https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple`。 |

镜像也支持 docker-levilamina-server 的其他变量（`TZ`、`LANG`、`WINEDEBUG`）。控制台、模组和 Docker Compose 的用法见 [Docker 教程](https://levimc.org/tutorials/zh-Hans/server/docker/)。

由 0.3.0 之前的镜像搭建的服务器，会在首次启动时自动迁移：`lip` 接管游戏和 LeviLamina，Python 会重新安装到新的 Wine 前缀 `/data/.lip/wine`。旧前缀 `/data/.wine` 不再使用，可以删除。
