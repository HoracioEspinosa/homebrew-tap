# homebrew-tap

Homebrew tap for [`HoracioEspinosa/engram`](https://github.com/HoracioEspinosa/engram), the
ClaroDrive-configured fork of [engram](https://github.com/Gentleman-Programming/engram). This
is **not** the upstream project's tap (`gentleman-programming/tap`) — installing from that one
gives you upstream engram, without the ClaroDrive cloud configuration or this fork's fixes.

## Install

```bash
brew install HoracioEspinosa/tap/engram
```

`HoracioEspinosa/engram` is a **private** repository. Its release binaries are not reachable by
an unauthenticated download, so `brew install`/`brew upgrade` need a GitHub token with read
access to that repository, exported as `HOMEBREW_GITHUB_API_TOKEN`:

```bash
export HOMEBREW_GITHUB_API_TOKEN=<a token with read access to HoracioEspinosa/engram>
brew install HoracioEspinosa/tap/engram
```

Without it, the formula fails fast with a message naming exactly this — it does not fail with an
opaque `404`.

If the tap itself is unreachable, or you would rather not authenticate Homebrew at all, download
the binary directly and verify it against the release's own `checksums.txt` — see
[the fork's README](https://github.com/HoracioEspinosa/engram#readme) and
[docs/INSTALLATION.md](https://github.com/HoracioEspinosa/engram/blob/main/docs/INSTALLATION.md).

## Updating the formula for a new release

The formula pins two things per architecture that a version bump alone does not fix: the
numeric **GitHub asset id** of each `darwin` tarball (the download goes through the
authenticated REST API's asset endpoint, since the repository is private — not the public
`/releases/download/<tag>/<file>` URL) and that tarball's **sha256**, read from the release's own
`checksums.txt`, never recomputed by hand.

`scripts/update-formula.sh` resolves both and rewrites `Formula/engram.rb`:

```bash
bash scripts/update-formula.sh v1.20.1-cd.1
```

It prints a diff and the exact commands to test and commit — it does not commit on its own.
Test the result before committing:

```bash
HOMEBREW_GITHUB_API_TOKEN=$(gh auth token) brew install --verbose HoracioEspinosa/tap/engram
```

Requires `gh`, authenticated with read access to `HoracioEspinosa/engram`.

## Scope

Only `darwin_arm64` and `darwin_amd64` are covered — that is the team's actual hardware today.
The fork also publishes `linux_amd64`/`linux_arm64` tarballs; adding them to the formula is the
same `on_linux` block pattern as `on_macos`/`on_arm`/`on_intel`, with their own asset ids and
`checksums.txt` entries. `scripts/update-formula.sh` would need the corresponding filenames added
before it could resolve them too.
