# homebrew-tap

Homebrew tap for [`HoracioEspinosa/engram`](https://github.com/HoracioEspinosa/engram), the
ClaroDrive-configured fork of [engram](https://github.com/Gentleman-Programming/engram). This
is **not** the upstream project's tap (`gentleman-programming/tap`) — installing from that one
gives you upstream engram, without the ClaroDrive cloud configuration or this fork's fixes.

## Requirement: macOS

The tap ships a single artifact, a Homebrew **cask** (`Casks/engram-custom.rb`). Homebrew Cask
only installs on macOS — it is not available on Linux at all, regardless of what platforms the
cask's own download URLs cover. On Linux, install from the release archive or the container
image instead; see [`docs/INSTALLATION.md`](https://github.com/HoracioEspinosa/engram/blob/main/docs/INSTALLATION.md)
in the fork.

## Install

```bash
brew install --cask HoracioEspinosa/tap/engram-custom
```

`HoracioEspinosa/engram` is a public repository, so no GitHub token or authentication is needed
to install or upgrade.

Upgrade to latest:

```bash
brew update && brew upgrade --cask engram-custom
```

> **Migrating from the formula?** Before this tap dropped `Formula/engram.rb`, some machines
> installed engram as a formula. A formula and a cask can coexist under different names, but only
> one binary should be on `PATH`. If `engram --version` looks stale after switching, uninstall the
> formula first:
> ```bash
> brew uninstall engram
> brew install --cask HoracioEspinosa/tap/engram-custom
> ```

## The cask is generated, not hand-written

`Casks/engram-custom.rb` carries a `DO NOT EDIT` header for a reason: GoReleaser writes it from
`.goreleaser.custom.yaml` in the fork and pushes it to this tap on every tagged release. There is
no manual update step and no script in this repository that touches it — editing it by hand would
only survive until the next release overwrites it. A fix to the cask's shape (its download URLs,
hooks, caveats, stanza layout) goes in the fork's `.goreleaser.custom.yaml`, never here.

## Scope

Only `darwin_arm64` and `darwin_amd64` are actually reachable through this tap, because Homebrew
Cask is macOS-only by design — see [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux).
The generated cask also declares `on_linux` blocks with `linux_amd64`/`linux_arm64` URLs (the fork
publishes those tarballs too), but `brew install --cask` never reaches them on any platform: this
is not a gap that adding entries here can close, unlike the old formula's per-architecture list.
