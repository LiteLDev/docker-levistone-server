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
    xvfb-run -a wine /opt/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1
    rm -f /opt/python-installer.exe
fi

export WINEDEBUG="${WINEDEBUG:--all}"

if [ ! -f "bedrock_server_mod.exe" ]; then
    if [ -n "$GITHUB_MIRROR_URL" ]; then
        lip config set github_proxy "$GITHUB_MIRROR_URL"
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

# LeviLamina >= 26.60.0 loads LeviStone from mods/ instead of plugins/.
if [ "$VERSION" = "LATEST" ]; then
    LEVISTONE_TARGET="mods"
else
    LEVILAMINA_MAJOR=$(echo "$VERSION" | cut -d. -f1 | tr -cd '0-9')
    LEVILAMINA_MINOR=$(echo "$VERSION" | cut -d. -f2 | tr -cd '0-9')
    LEVILAMINA_PATCH=$(echo "$VERSION" | cut -d. -f3 | tr -cd '0-9')
    LEVILAMINA_VERSION_NUM=$(( ${LEVILAMINA_MAJOR:-0} * 100000 + ${LEVILAMINA_MINOR:-0} * 1000 + ${LEVILAMINA_PATCH:-0} ))
    if [ "$LEVILAMINA_VERSION_NUM" -ge 2660000 ]; then
        LEVISTONE_TARGET="mods"
    else
        LEVISTONE_TARGET="plugins"
    fi
fi

if [ ! -d "$LEVISTONE_TARGET/EndstoneRuntime" ]; then
    if [ -n "$PYPI_MIRROR_URL" ]; then
        wine pip config set global.index-url "$PYPI_MIRROR_URL"
    fi
    if [ -n "$LEVISTONE_VERSION" ]; then
        wine pip install levistone==${LEVISTONE_VERSION} --target "$LEVISTONE_TARGET/EndstoneRuntime"
    else
        wine pip install levistone --target "$LEVISTONE_TARGET/EndstoneRuntime"
    fi
fi

(cat | wine bedrock_server_mod.exe) 2>/dev/null
