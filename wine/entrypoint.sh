#! /usr/bin/env sh

stty size cols 80

VERSION="${VERSION:-LATEST}"

if [ "$EULA" != "TRUE" ]
then
    echo "You must accept the Minecraft EULA to run the server"
    echo "Set the environment variable EULA to TRUE to accept it"
    exit 1
fi

if [ ! -d "/data/.tmp" ]
then
    mkdir -p /data/.tmp
fi

if [ ! -d "/data/.wine" ]
then
    winecfg
    xvfb-run -a winetricks -q vcrun2026
fi

if [ ! -d "/data/.wine/drive_c/Program Files/dotnet" ]
then
    xvfb-run -a winetricks -q dotnet10
fi

if [ ! -d "/data/.wine/drive_c/Program Files/Python313" ]
then
    wget -q https://www.python.org/ftp/python/3.13.12/python-3.13.12-amd64.exe -O /data/.tmp/python-installer.exe
    xvfb-run -a wine /data/.tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1
    rm -f /data/.tmp/python-installer.exe
fi

export WINEDEBUG="${WINEDEBUG:--all}"

if [ ! -f "bedrock_server_mod.exe" ]; then
    if [ -n "$GITHUB_MIRROR_URL" ]; then
        lip config set github_proxy "$GITHUB_MIRROR_URL"
    fi
    
    if [ -n "$GO_MODULE_PROXY_URL" ]; then
        lip config set go_module_proxy "$GO_MODULE_PROXY_URL"
    fi
    
    if [ "$VERSION" = "LATEST" ]; then
        lip install github.com/LiteLDev/LeviLamina
    else
        lip install github.com/LiteLDev/LeviLamina@"$VERSION"
    fi
    
    if [ -n "$PACKAGES" ]; then
        lip install $PACKAGES
    fi
fi

if [ ! -d "plugins/EndstoneRuntime" ]; then
    if [ -n "$PYPI_MIRROR_URL" ]; then
        wine pip config set global.index-url "$PYPI_MIRROR_URL"
    fi
    if [ -n "$LEVISTONE_VERSION" ]; then
        wine pip install levistone==${LEVISTONE_VERSION} --target plugins/EndstoneRuntime
    else
        wine pip install levistone --target plugins/EndstoneRuntime
    fi
fi

(cat | wine bedrock_server_mod.exe) 2>/dev/null
