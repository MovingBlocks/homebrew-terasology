# homebrew-terasology

Homebrew tap for [Terasology](https://terasology.org), a voxel-based game engine (Minecraft-inspired).

## Install

```sh
brew tap MovingBlocks/terasology
brew install terasology            # pinned, stable release (currently v5.4.0-rc.1)
brew install terasology-latest-bin # rolling latest CI build from develop
```

Both are independent - you can install one or both side by side. Each installs a real macOS app
(**Terasology.app** / **Terasology Latest.app** in `/Applications`, launchable from Launchpad,
Spotlight, or Finder) plus a matching terminal command (`terasology` / `terasology-latest-bin`).
Both run the exact same game either way, just from different sources.

On Homebrew versions with tap trust enforcement, the first install may ask you to run
`brew trust MovingBlocks/terasology` before it'll load anything from a new third-party tap.

## What these install

Both are [Casks](https://docs.brew.sh/Cask-Cookbook), not Formulae, because neither download is a
Homebrew-built, reproducible artifact - they're upstream's own prebuilt binaries.

- **`terasology`** downloads a specific tagged GitHub release
  (`releases/download/v<version>/TerasologyOmega.zip`), pinned to a real, verified `sha256`. This
  mirrors the Arch Linux `terasology` AUR package. Note: as of this writing, `v5.4.0` itself is
  still an unpublished draft with no release assets - `v5.4.0-rc.1` is the latest tag that actually
  has a `TerasologyOmega.zip` attached, so that's what's pinned; bump `version`/`sha256` in
  `Casks/terasology.rb` once a real `v5.4.0` (or later) release ships.
- **`terasology-latest-bin`** downloads the latest successful "Omega" CI build (engine + curated
  content modules) from `jenkins.terasology.io` - mirrors the Arch Linux `terasology-latest-bin`
  AUR package. There's no fixed version: every `brew install`/`brew upgrade` fetches whatever
  `develop` currently builds, which is why it uses `sha256 :no_check` - there's no stable checksum
  to pin for a URL that always means "whatever's newest right now."

Neither upstream build ships a macOS `.app` bundle - just loose files (jars, natives, a Unix launch
script) meant to be run from within their own directory. Each cask's `preflight` step (see
`Casks/*.rb`) wraps that into a proper `.app` bundle with its own `Info.plist` and icon
(`resources/Terasology.icns`, extracted from the icons the engine itself already ships in its jar) -
that's also why they can't just symlink the upstream launch script directly: it never actually `cd`s
to its own resolved location before its relative `-jar libs/Terasology.jar`, so a double-click
launch (working directory unpredictable) would fail even though a `./Terasology` from a terminal in
the right directory happens to work.

Requires a JDK, installed automatically via the `openjdk@17` formula dependency - pinned to 17
specifically, not the generic (latest) `openjdk` formula. Terasology's module sandbox depends on
`SecurityManager`, which is disabled by default starting JDK 18 and removed entirely on JDK 24+
(JEP 486); only JDK 17 gets a working sandbox with no extra JVM flags needed. See
[MovingBlocks/Terasology#5357](https://github.com/MovingBlocks/Terasology/issues/5357) for the
full architecture discussion.

## Updating

```sh
brew upgrade terasology            # only re-downloads if Casks/terasology.rb's version/sha256 changed
brew upgrade terasology-latest-bin # always re-downloads - the URL means "whatever's newest"
```

## Uninstalling

```sh
brew uninstall --zap terasology
brew uninstall --zap terasology-latest-bin
```

`--zap` also removes `~/.terasology` (save games, config) - shared between both, since they're the
same game.
