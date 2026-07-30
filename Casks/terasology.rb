cask "terasology" do
  version "5.4.0-rc.1"
  sha256 "5a0f8860ffd18f6900139fcf035e634e14ca4e60111f3734e07f1d42412cd0a3"

  url "https://github.com/MovingBlocks/Terasology/releases/download/v#{version}/TerasologyOmega.zip"
  name "Terasology"
  desc "Yet another high resolution game with blocks like Minecraft"
  homepage "https://terasology.org"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "openjdk"

  preflight do
    bundle = "#{staged_path}/Terasology.app"
    contents = "#{bundle}/Contents"
    macos_dir = "#{contents}/MacOS"
    resources = "#{contents}/Resources"
    game_dir = "#{resources}/game"

    # Same layout as terasology-latest-bin's build (see that cask for the full
    # explanation): loose files at the zip root, no wrapper folder, wrapped here
    # into a real .app for Launchpad/Dock/Spotlight instead of CLI-only.
    FileUtils.mkdir_p game_dir
    Dir.children(staged_path).each do |entry|
      next if entry == "Terasology.app"

      FileUtils.mv "#{staged_path}/#{entry}", "#{game_dir}/#{entry}"
    end

    FileUtils.rm_rf "#{game_dir}/natives/linux"
    FileUtils.rm_rf "#{game_dir}/natives/windows"
    FileUtils.rm_f "#{game_dir}/Terasology.bat"
    FileUtils.rm_f "#{game_dir}/Terasology"

    FileUtils.mkdir_p macos_dir
    FileUtils.cp cask.tap.path/"resources/Terasology.icns", "#{resources}/Terasology.icns"

    File.write("#{contents}/Info.plist", <<~XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleName</key><string>Terasology</string>
        <key>CFBundleDisplayName</key><string>Terasology</string>
        <key>CFBundleIdentifier</key><string>org.terasology.game</string>
        <key>CFBundleVersion</key><string>#{version}</string>
        <key>CFBundleShortVersionString</key><string>#{version}</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleExecutable</key><string>terasology</string>
        <key>CFBundleIconFile</key><string>Terasology.icns</string>
        <key>LSApplicationCategoryType</key><string>public.app-category.games</string>
        <key>NSHighResolutionCapable</key><true/>
      </dict>
      </plist>
    XML

    File.write("#{macos_dir}/terasology", <<~SH)
      #!/bin/bash
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
    FileUtils.chmod 0755, "#{macos_dir}/terasology"
  end

  app "Terasology.app"
  binary "#{appdir}/Terasology.app/Contents/MacOS/terasology"

  zap trash: "~/.terasology"
end
