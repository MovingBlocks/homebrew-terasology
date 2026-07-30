cask "terasology-latest-bin" do
  version :latest
  sha256 :no_check

  url "https://jenkins.terasology.io/job/Terasology/job/Omega/job/develop/lastSuccessfulBuild/artifact/distros/omega/build/distributions/TerasologyOmega.zip"
  name "Terasology"
  desc "Yet another high resolution game with blocks like Minecraft"
  homepage "https://terasology.org"

  livecheck do
    url "https://jenkins.terasology.io/job/Terasology/job/Omega/job/develop/lastSuccessfulBuild/artifact/VERSION"
    regex(/Build number:\s*(\d+)/i)
  end

  depends_on formula: "openjdk"

  preflight do
    bundle = "#{staged_path}/Terasology Latest.app"
    contents = "#{bundle}/Contents"
    macos_dir = "#{contents}/MacOS"
    resources = "#{contents}/Resources"
    game_dir = "#{resources}/game"

    # The zip extracts LICENSE, NOTICE, VERSION, Terasology, Terasology.bat, libs/,
    # natives/, modules/ directly at the top level (no wrapper folder) - move all of
    # it into Contents/Resources/game so it doesn't collide with the bundle's own
    # Contents/* layout, then wrap it as a real .app for Launchpad/Dock/Spotlight.
    FileUtils.mkdir_p game_dir
    Dir.children(staged_path).each do |entry|
      next if entry == "Terasology Latest.app"

      FileUtils.mv "#{staged_path}/#{entry}", "#{game_dir}/#{entry}"
    end

    FileUtils.rm_rf "#{game_dir}/natives/linux"
    FileUtils.rm_rf "#{game_dir}/natives/windows"
    FileUtils.rm_f "#{game_dir}/Terasology.bat"
    # Replaced by our own Contents/MacOS/terasology-latest-bin below: this script
    # never cds to its own resolved APP_HOME before its relative
    # `-jar libs/Terasology.jar`, so it only works if launched with CWD already at
    # the distribution root - not true for a Launch Services double-click.
    FileUtils.rm_f "#{game_dir}/Terasology"

    FileUtils.mkdir_p macos_dir
    FileUtils.cp cask.tap.path/"resources/Terasology.icns", "#{resources}/Terasology.icns"

    File.write("#{contents}/Info.plist", <<~XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleName</key><string>Terasology Latest</string>
        <key>CFBundleDisplayName</key><string>Terasology Latest</string>
        <key>CFBundleIdentifier</key><string>org.terasology.game.latest</string>
        <key>CFBundleVersion</key><string>#{version}</string>
        <key>CFBundleShortVersionString</key><string>#{version}</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleExecutable</key><string>terasology-latest-bin</string>
        <key>CFBundleIconFile</key><string>Terasology.icns</string>
        <key>LSApplicationCategoryType</key><string>public.app-category.games</string>
        <key>NSHighResolutionCapable</key><true/>
      </dict>
      </plist>
    XML

    File.write("#{macos_dir}/terasology-latest-bin", <<~SH)
      #!/bin/bash
      # Resolve our own real location - Launch Services invokes this by absolute
      # path, but a `terasology-latest-bin` symlink on PATH also points straight
      # here, so this must work either way, and the game needs CWD at
      # Contents/Resources/game (see the tap README for why: its -jar argument
      # is relative, not resolved against the executable's own directory).
      SELF="$0"
      while [ -h "$SELF" ]; do
        DIR="$(cd -P "$(dirname "$SELF")" && pwd)"
        SELF="$(readlink "$SELF")"
        case "$SELF" in
          /*) ;;
          *) SELF="$DIR/$SELF" ;;
        esac
      done
      HERE="$(cd -P "$(dirname "$SELF")" && pwd)"
      cd "$HERE/../Resources/game" || exit 1
      exec "#{HOMEBREW_PREFIX}/opt/openjdk/bin/java" -jar libs/Terasology.jar "$@"
    SH
    FileUtils.chmod 0755, "#{macos_dir}/terasology-latest-bin"
  end

  app "Terasology Latest.app"
  binary "#{appdir}/Terasology Latest.app/Contents/MacOS/terasology-latest-bin"

  zap trash: "~/.terasology"
end
