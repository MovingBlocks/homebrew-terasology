cask "terasology-latest-bin" do
  version "5.4.0"
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
    FileUtils.rm_rf "#{staged_path}/natives/linux"
    FileUtils.rm_rf "#{staged_path}/natives/windows"
    FileUtils.rm_f "#{staged_path}/Terasology.bat"
    File.write("#{staged_path}/terasology-latest-bin", <<~SH)
      #!/bin/bash
      cd "#{caskroom_path}/app" || exit 1
      exec "#{HOMEBREW_PREFIX}/opt/openjdk/bin/java" -jar libs/Terasology.jar "$@"
    SH
    FileUtils.chmod 0755, "#{staged_path}/terasology-latest-bin"
  end

  artifact ".", target: "#{caskroom_path}/app"

  binary "#{caskroom_path}/app/terasology-latest-bin"

  zap trash: "~/.terasology"
end
