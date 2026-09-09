# homebrew-tap

Homebrew tap for [`HoracioEspinosa/engram`](https://github.com/HoracioEspinosa/engram), the
ClaroDrive-configured fork of [engram](https://github.com/Gentleman-Programming/engram). This
is **not** the upstream project's tap (`gentleman-programming/tap`) — installing from that one
gives you upstream engram, without the ClaroDrive cloud configuration or this fork's fixes.

## Install

```bash
brew install HoracioEspinosa/tap/engram
```

`HoracioEspinosa/engram` is a public repository, so no GitHub token or authentication is needed
to install or upgrade.

## Updating the formula for a new release

The formula's download URL is derived from `version` alone — the repository is public, so
nothing needs resolving there. The one thing a version bump does not fix by itself is each
architecture's **sha256**, read from the release's own `checksums.txt`, never recomputed by hand.

`scripts/update-formula.sh` resolves both and rewrites `Formula/engram.rb`:

```bash
bash scripts/update-formula.sh v1.20.1-cd.1
```

It prints a diff and the exact commands to test and commit — it does not commit on its own.
Test the result before committing:

```bash
brew install --verbose HoracioEspinosa/tap/engram
```

Requires only `curl`.

## Scope

Only `darwin_arm64` and `darwin_amd64` are covered — that is the team's actual hardware today.
The fork also publishes `linux_amd64`/`linux_arm64` tarballs; adding them to the formula is the
same `on_linux` block pattern as `on_macos`/`on_arm`/`on_intel`, with their own `checksums.txt`
entries. `scripts/update-formula.sh` would need the corresponding filenames added before it could
resolve them too.
