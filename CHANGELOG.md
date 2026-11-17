# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-11-17

### Changed

- Built on docker-levilamina-server 0.9.0 (lip v0.41.0). The Wine image runs Python and pip with the Wine that lip
  installs, in the Wine prefix lip runs the server in (`/data/.lip/wine`), instead of the Wine, winetricks and Xvfb
  that the base image no longer has, and the Python installer runs without a display with the null graphics driver of
  Wine; the old prefix `/data/.wine` is no longer used and can be deleted
- Both images set the server up with `lip install --accept-eula` and run it with `lip run`: `docker stop` now types
  `stop` into the server, which saves the world and exits
- The images no longer install the .NET runtime (lip is self-contained)
- The compose files give the server one minute to stop (`stop_grace_period`)
- A server that an earlier Wine image set up is migrated on its first start: `lip setup` turns its `tooth_lock.json`
  into the state file of lip v0.41, and Python is installed again into the new Wine prefix
- The README documents every environment variable

### Fixed

- The Wine image no longer runs the Python installer on every start: it checked for Python 3.13 but installed 3.14,
  and deleted the installer after the first run

## [0.2.0] - 2026-11-04

### Changed

- Synced with upstream image

## [0.1.3] - 2026-04-14

### Changed

- Synced with upstream image

## [0.1.2] - 2026-03-27

### Changed

- Download Python when build

### Fixed

- Fixed entrypoint override for Windows image

## [0.1.1] - 2026-03-27

### Fixed

- Fixed entrypoint overwrite

## [0.1.0] - 2026-03-27

- First release

[Unreleased]: https://github.com/LiteLDev/docker-levistone-server/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/LiteLDev/docker-levistone-server/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/LiteLDev/docker-levistone-server/compare/v0.1.3...v0.2.0
[0.1.3]: https://github.com/LiteLDev/docker-levistone-server/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/LiteLDev/docker-levistone-server/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/LiteLDev/docker-levistone-server/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/LiteLDev/docker-levistone-server/releases/tag/v0.1.0
