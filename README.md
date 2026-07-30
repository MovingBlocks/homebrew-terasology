# homebrew-terasology

Homebrew tap for [Terasology](https://terasology.org), a voxel-based game engine (Minecraft-inspired).

## Install

```sh
brew tap soloturn/terasology
brew install terasology-latest-bin
terasology-latest-bin
```

On Homebrew versions with tap trust enforcement, the first install may ask you to run
`brew trust soloturn/terasology` before it'll load anything from a new third-party tap.

## What this installs

`terasology-latest-bin` is a [Cask](https://docs.brew.sh/Cask-Cookbook) that downloads the latest
successful "Omega" CI build (engine + curated content modules) from `jenkins.terasology.io` - the
same rolling-build artifact the Arch Linux `terasology-latest-bin` AUR package uses. There is no
fixed release version: every `brew install` or `brew upgrade` fetches whatever `develop` currently
builds, which is why it's a cask (`sha256 :no_check`) rather than a formula - Homebrew formulae
require a pinned, verifiable checksum, which a "latest CI build" URL can't provide by design.

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
