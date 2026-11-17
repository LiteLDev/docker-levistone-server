@echo off
setlocal

if "%VERSION%"=="" set "VERSION=LATEST"

if not "%EULA%"=="TRUE" (
    echo You must accept the Minecraft EULA to run the server
    echo Set the environment variable EULA to TRUE to accept it
    exit /b 1
)

rem lip installs the Visual C++ runtime itself, but on Windows it asks for elevation to do so,
rem which a container cannot grant: install it here, and lip finds it installed.
if not exist "C:\Windows\System32\vcruntime140_1.dll" (
    powershell -Command "Invoke-WebRequest -Uri https://aka.ms/vc14/vc_redist.x64.exe -OutFile vc_redist.x64.exe"
    vc_redist.x64.exe /install /quiet /norestart
    del vc_redist.x64.exe
)

if not "%GITHUB_MIRROR_URL%"=="" (
    lip.exe config set github_proxy %GITHUB_MIRROR_URL%
)

rem The first start sets the server up: lip installs the game that fits LeviLamina, LeviLamina,
rem and the packages of PACKAGES in one go.
if not exist "bedrock_server_mod.exe" (
    if "%VERSION%"=="LATEST" (
        lip.exe install --accept-eula github.com/LiteLDev/LeviLamina %PACKAGES%
    ) else (
        lip.exe install --accept-eula "github.com/LiteLDev/LeviLamina@%VERSION%" %PACKAGES%
    )
    if errorlevel 1 exit /b 1
)

rem LeviLamina >= 26.60.0 loads LeviStone from mods\ instead of plugins\.
set "LEVISTONE_TARGET=mods"
if "%VERSION%"=="LATEST" goto :levistone_target_ready

set "LEVILAMINA_VERSION_NUM=0"
for /f "tokens=1,2,3 delims=.-+" %%a in ("%VERSION%") do (
    set "LEVILAMINA_MAJOR=%%a"
    set "LEVILAMINA_MINOR=%%b"
    set "LEVILAMINA_PATCH=%%c"
)
set "LEVILAMINA_MAJOR=%LEVILAMINA_MAJOR:v=%"
set "LEVILAMINA_MINOR=%LEVILAMINA_MINOR:v=%"
set "LEVILAMINA_PATCH=%LEVILAMINA_PATCH:v=%"
set /a LEVILAMINA_VERSION_NUM=LEVILAMINA_MAJOR*100000+LEVILAMINA_MINOR*1000+LEVILAMINA_PATCH >nul 2>&1
if %LEVILAMINA_VERSION_NUM% LSS 2660000 set "LEVISTONE_TARGET=plugins"

:levistone_target_ready
if not exist "%LEVISTONE_TARGET%\EndstoneRuntime\" (
    if not "%PYPI_MIRROR_URL%"=="" (
        pip config set global.index-url %PYPI_MIRROR_URL%
    )
    if not "%LEVISTONE_VERSION%"=="" (
        pip install --disable-pip-version-check levistone==%LEVISTONE_VERSION% --target %LEVISTONE_TARGET%/EndstoneRuntime
    ) else (
        pip install --disable-pip-version-check levistone --target %LEVISTONE_TARGET%/EndstoneRuntime
    )
    if errorlevel 1 exit /b 1
)

rem lip runs the server, passes the console through, and types `stop` when the container stops.
lip.exe run
