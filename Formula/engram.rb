class Engram < Formula
  desc "Persistent memory for AI coding agents (ClaroDrive fork of engram)"
  homepage "https://github.com/HoracioEspinosa/engram"
  version "1.20.0-cd.2"
  license "MIT"

  # HoracioEspinosa/engram is a public repository, so each release asset is
  # reachable through the plain GitHub release download URL — no token, no
  # authenticated REST API asset endpoint. Every sha256 below comes straight
  # from the release's own checksums.txt, never recomputed here.
  on_arm do
    url "https://github.com/HoracioEspinosa/engram/releases/download/v#{version}/engram_#{version}_darwin_arm64.tar.gz"
    sha256 "08bb9c9a3b1532582b55b8a435c4ab8632859b9dd7ecf798cfc20a09f160c653"
  end

  on_intel do
    url "https://github.com/HoracioEspinosa/engram/releases/download/v#{version}/engram_#{version}_darwin_amd64.tar.gz"
    sha256 "b985f825fd20c8bb5adda7dcf61e7149eec2b613697c8d612b64b805e6b3a47b"
  end

  def install
    bin.install "engram"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engram --help")
  end
end
