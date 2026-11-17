#!/usr/bin/env sh
set -e

VERSION="${VERSION:-LATEST}"

if [ "$EULA" != "TRUE" ]; then
    echo "You must accept the Minecraft EULA to run the server"
    echo "Set the environment variable EULA to TRUE to accept it"
    exit 1
fi

if [ -n "$GITHUB_MIRROR_URL" ]; then
    lip config set github_proxy "$GITHUB_MIRROR_URL"
fi

# A server that an image with lip v0.x set up has a tooth_lock.json and no state file of lip
# v0.41, so lip finds no game in it. A setup with its game and LeviLamina version makes the state
# file, and keeps the worlds, the settings and the other mods.
if [ -f tooth_lock.json ] && [ ! -f .lip/state.json ]; then
    INSTALLED="$(lip list)"
    GAME="$(echo "$INSTALLED" | sed -n 's|.*github\.com/LiteLDev/bds@\([^ ]*\).*|\1|p' | head -n 1)"
    LOADER_VERSION="$(echo "$INSTALLED" | sed -n 's|.*github\.com/LiteLDev/LeviLamina@\([^ ]*\).*|\1|p' | head -n 1)"
    lip setup --accept-eula --game "$GAME" --loader "levilamina@$LOADER_VERSION"
fi

# The first start sets the server up: lip installs the game that fits LeviLamina, LeviLamina, and
# the packages of PACKAGES in one go, and before that its Wine and the Visual C++ runtime.
if [ ! -f bedrock_server_mod.exe ]; then
    if [ "$VERSION" = "LATEST" ]; then
        LOADER="github.com/LiteLDev/LeviLamina"
    else
        LOADER="github.com/LiteLDev/LeviLamina@$VERSION"
    fi

    # shellcheck disable=SC2086 # PACKAGES is a list separated by spaces
    lip install --accept-eula "$LOADER" $PACKAGES
fi

# Python and pip run under the Wine of lip, in the Wine prefix that lip runs the server in.
WINE="$(find "${XDG_DATA_HOME:-$HOME/.local/share}/lip/wine" -path '*/bin/wine' | head -n 1)"
if [ -z "$WINE" ]; then
    echo "The Wine of lip is not installed"
    exit 1
fi
export WINEPREFIX="${WINEPREFIX:-$PWD/.lip/wine}"
export WINEDEBUG="${WINEDEBUG:--all}"

find_python() {
    ls -d "$WINEPREFIX"/drive_c/Program\ Files/Python3*/python.exe 2>/dev/null | head -n 1
}

# The Python installer opens a window even when quiet, and the container has no display: the null
# graphics driver of Wine lets it, and the server, which is a console program, does not mind.
if [ -z "$(find_python)" ]; then
    "$WINE" reg add 'HKCU\Software\Wine\Drivers' /v Graphics /d null /f
    "$WINE" /opt/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    "${WINE}server" -w
fi
PYTHON="$(find_python)"

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
        "$WINE" "$PYTHON" -m pip config set global.index-url "$PYPI_MIRROR_URL"
    fi
    if [ -n "$LEVISTONE_VERSION" ]; then
        LEVISTONE="levistone==$LEVISTONE_VERSION"
    else
        LEVISTONE="levistone"
    fi
    "$WINE" "$PYTHON" -m pip install --disable-pip-version-check "$LEVISTONE" --target "$LEVISTONE_TARGET/EndstoneRuntime"
    "${WINE}server" -w
fi

# lip runs bedrock_server_mod.exe under its Wine, passes the console through, and on SIGTERM
# (docker stop) types `stop` so that the server saves the world and exits.
exec lip run
