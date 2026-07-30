# homebrew-terasology

Homebrew tap for [Terasology](https://terasology.org), a voxel-based game engine (Minecraft-inspired).

## Install

```sh
brew tap soloturn/terasology
brew install terasology-latest-bin
```

This installs both **Terasology.app** in `/Applications` (launch it from Launchpad, Spotlight, or
Finder like any other Mac app) and a `terasology-latest-bin` command on your `PATH` for launching
from a terminal. Both run the exact same thing.

On Homebrew versions with tap trust enforcement, the first install may ask you to run
`brew trust soloturn/terasology` before it'll load anything from a new third-party tap.

## What this installs

`terasology-latest-bin` is a [Cask](https://docs.brew.sh/Cask-Cookbook) that downloads the latest
successful "Omega" CI build (engine + curated content modules) from `jenkins.terasology.io` - the
same rolling-build artifact the Arch Linux `terasology-latest-bin` AUR package uses. There is no
fixed release version: every `brew install` or `brew upgrade` fetches whatever `develop` currently
builds, which is why it's a cask (`sha256 :no_check`) rather than a formula - Homebrew formulae
require a pinned, verifiable checksum, which a "latest CI build" URL can't provide by design.

The upstream build is a plain folder of files (jars, natives, a Unix launch script) with no macOS
`.app` bundle of its own. The cask wraps it into one at install time - see `preflight` in
`Casks/terasology-latest-bin.rb` - and supplies an icon (`resources/Terasology.icns`, extracted
from the icons the engine itself already ships in its jar).

Requires a JDK, installed automatically via the `openjdk` formula dependency.

## Updating

```sh
brew upgrade terasology-latest-bin
```

Since the upstream URL always points at "latest successful build", `brew upgrade` re-downloads
regardless of the formula's own `version` field.

## Uninstalling

```sh
brew uninstall --zap terasology-latest-bin
```

`--zap` also removes `~/.terasology` (save games, config).
