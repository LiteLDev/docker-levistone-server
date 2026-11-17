# docker-levistone-server

English | [简体中文](README.zh.md)

Docker images of a Bedrock Dedicated Server with [LeviLamina](https://github.com/LiteLDev/LeviLamina) and [LeviStone](https://github.com/LiteLDev/LeviStone), which runs Endstone plugins written in Python. They are built on the images of [docker-levilamina-server](https://github.com/LiteLDev/docker-levilamina-server) and add Python and LeviStone.

| Image | Runs on |
| --- | --- |
| `ghcr.io/liteldev/levistone-server:latest-wine` | Linux containers: `lip` runs natively and runs the Windows server under a Wine it installs itself |
| `ghcr.io/liteldev/levistone-server:latest-windows` | Windows containers |

## Installation

To start the server in a Linux container, run:

```sh
docker run -d -it --name levistone -e EULA=TRUE -p 19132:19132/udp -p 19132:19132/tcp -v levistone-server-data:/data ghcr.io/liteldev/levistone-server:latest-wine
```

Or, in a Windows container:

```pwsh
docker run -d -it --name levistone -e EULA=TRUE -p 19132:19132/udp -p 19132:19132/tcp -v levistone-server-data:C:\data ghcr.io/liteldev/levistone-server:latest-windows
```

On the first start the container sets the server up in the volume: `lip` installs its Wine and the Visual C++ runtime (Wine image), the game, LeviLamina and the packages of `PACKAGES`; then the container installs Python into the Wine prefix (Wine image) and LeviStone into `mods/EndstoneRuntime` with pip. This takes several minutes; later starts take seconds. Put Endstone plugins into `plugins/` in the volume.

Stop the server with `docker stop -t 60 levistone`: `lip` types `stop` into the server, which saves the world and exits. The compose files ([wine/compose.yaml](wine/compose.yaml), [windows/compose.yaml](windows/compose.yaml)) set the same minute (`stop_grace_period`).

### Environment variables

| Variable | Default | Meaning |
| --- | --- | --- |
| `EULA` | | Must be `TRUE`: you accept the [Minecraft End User License Agreement](https://www.minecraft.net/eula). |
| `VERSION` | `LATEST` | The LeviLamina version to install, such as `26.60.7`. The game version follows from it. |
| `LEVISTONE_VERSION` | the latest | The LeviStone version to install, such as `0.11.15.post1` ([versions](https://pypi.org/project/levistone/#history)). It must fit the LeviLamina version. |
| `PACKAGES` | | Further `lip` packages to install on the first start, separated by spaces. |
| `GITHUB_MIRROR_URL` | | A GitHub mirror for the downloads of `lip`. |
| `PYPI_MIRROR_URL` | | A PyPI mirror for pip, such as `https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple`. |

The images accept the other variables of docker-levilamina-server too (`TZ`, `LANG`, `WINEDEBUG`); see the [Docker tutorial](https://levimc.org/tutorials/server/docker/) for the console, mods and Docker Compose.

A server set up by an image before 0.3.0 is migrated on its first start: `lip` takes over the game and LeviLamina, and Python is installed again into the new Wine prefix `/data/.lip/wine`. The old prefix `/data/.wine` is no longer used and can be deleted.
