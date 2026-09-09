class Engram < Formula
  desc "Persistent memory for AI coding agents (ClaroDrive fork of engram)"
  homepage "https://github.com/HoracioEspinosa/engram"
  version "1.20.0-cd.2"
  license "MIT"

  # HoracioEspinosa/engram is a PRIVATE repository, so its release assets are
  # not reachable by an unauthenticated request — the plain public download
  # URL 404s. Every asset is instead fetched through the authenticated
  # GitHub REST API (the asset-id endpoint, not the browser download URL),
  # carrying the token as a header. `Authorization` headers on `github.com`/
  # `api.github.com` hosts are stripped by Homebrew after a redirect (see
  # CurlDownloadStrategy), which is exactly why the asset endpoint (no
  # redirect to a different host) is used here instead of the release page's
  # `/releases/download/...` URL.
  #
  # HOMEBREW_GITHUB_API_TOKEN is the one secret Homebrew does not defer
  # during formula evaluation (see extend/ENV/sensitive.rb,
  # clear_sensitive_environment_for_eval!), so it can be read directly here.
  # It must be a token with read access to HoracioEspinosa/engram.
  GITHUB_TOKEN = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", "")
  AUTH_HEADERS = [
    "Authorization: token #{GITHUB_TOKEN}",
    "Accept: application/octet-stream",
  ].freeze

  on_arm do
    url "https://api.github.com/repos/HoracioEspinosa/engram/releases/assets/551405068",
        headers: AUTH_HEADERS
    sha256 "08bb9c9a3b1532582b55b8a435c4ab8632859b9dd7ecf798cfc20a09f160c653"
  end

  on_intel do
    url "https://api.github.com/repos/HoracioEspinosa/engram/releases/assets/551405033",
        headers: AUTH_HEADERS
    sha256 "b985f825fd20c8bb5adda7dcf61e7149eec2b613697c8d612b64b805e6b3a47b"
  end

  def install
    if GITHUB_TOKEN.empty?
      odie <<~EOS
        HOMEBREW_GITHUB_API_TOKEN is not set.
        HoracioEspinosa/engram is a private repository — set a GitHub token
        with read access to it before installing:
          export HOMEBREW_GITHUB_API_TOKEN=<your token>
      EOS
    end
    bin.install "engram"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engram --help")
  end
end
