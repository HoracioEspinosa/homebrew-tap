# homebrew-tap

Homebrew tap for [`HoracioEspinosa/engram`](https://github.com/HoracioEspinosa/engram), the
ClaroDrive-configured fork of [engram](https://github.com/Gentleman-Programming/engram). This
is **not** the upstream project's tap (`gentleman-programming/tap`) — installing from that one
gives you upstream engram, without the ClaroDrive cloud configuration or this fork's fixes.

## Install (macOS and Linux)

```bash
brew install HoracioEspinosa/tap/engram-custom
```

`HoracioEspinosa/engram` is a public repository, so no GitHub token or authentication is needed
to install or upgrade. The formula is built for `darwin` and `linux`, `amd64` and `arm64` — the
same platforms the fork's release archives cover.

Upgrade to latest:

```bash
brew update && brew upgrade engram-custom
```

> **Migrating from the cask?** This tap used to ship `engram-custom` as a Homebrew **cask**,
> macOS-only — that's what `Casks/engram-custom.rb` was, before this. A cask and a formula can't
> both hold the same install, so if a machine has the cask, remove it first:
> ```bash
> brew uninstall --cask engram-custom
> brew install HoracioEspinosa/tap/engram-custom
> ```

## The formula is generated, not hand-written

`Formula/engram-custom.rb` carries a `DO NOT EDIT` header for a reason: GoReleaser writes it from
`.goreleaser.custom.yaml` in the fork and pushes it to this tap on every tagged release. There is
no manual update step and no script in this repository that touches it — editing it by hand would
only survive until the next release overwrites it. A fix to the formula's shape (its download
URLs, install steps, caveats) goes in the fork's `.goreleaser.custom.yaml`, never here.

This tap previously carried a hand-written `Formula/engram.rb`, pinned to whatever version someone
last remembered to update by hand, alongside a generated cask that a real release always kept
current — a silent divergence nobody was warned about. It was retired once the automation could
generate a formula on its own; there is exactly one artifact in this tap now, and it is always the
one the most recent release produced.

## Why a formula, and not a cask

Homebrew Cask only installs on macOS. This team needs `brew install` on Linux too, so the tap
serves a Homebrew **formula** instead: the one artifact type Homebrew supports on both platforms.
`brews` is the config key GoReleaser marked deprecated in favor of `homebrew_casks` for
precompiled binaries — deprecated, not removed: `goreleaser check` reports it with a
"uses deprecated properties" notice, not a hard failure, and it still generates a correct formula.
See the comment above `brews:` in the fork's `.goreleaser.custom.yaml` for the full reasoning.
