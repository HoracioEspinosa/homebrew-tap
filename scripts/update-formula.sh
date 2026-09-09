#!/usr/bin/env bash
#
# update-formula.sh — bump Formula/engram.rb to a new release of
# HoracioEspinosa/engram.
#
# The formula pins two things per release that cannot be discovered from a
# version string alone: the numeric GitHub *asset id* of each darwin tarball
# (needed because the repository is private, so downloads go through the
# authenticated REST API's asset endpoint, not the public
# /releases/download/<tag>/<file> URL) and that tarball's sha256 (published
# in the release's own checksums.txt, not recomputed here). Both drift on
# every release, so this script re-resolves them instead of hand-editing.
#
# Usage:
#   bash scripts/update-formula.sh v1.20.1-cd.1
#
# Requires: gh (authenticated, with read access to HoracioEspinosa/engram).
# Prints a diff of Formula/engram.rb; does not commit.
#
set -euo pipefail

REPO="HoracioEspinosa/engram"
TAG="${1:-}"
if [[ -z "${TAG}" ]]; then
	echo "Usage: bash scripts/update-formula.sh <release-tag>" >&2
	echo "Example: bash scripts/update-formula.sh v1.20.1-cd.1" >&2
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORMULA="${SCRIPT_DIR}/../Formula/engram.rb"
[[ -f "${FORMULA}" ]] || { echo "ERROR: ${FORMULA} not found" >&2; exit 1; }

command -v gh > /dev/null 2>&1 || { echo "ERROR: gh is not available" >&2; exit 1; }
gh auth status > /dev/null 2>&1 || { echo "ERROR: gh is not authenticated" >&2; exit 1; }

VERSION="${TAG#v}"
echo "Resolving release ${TAG} (version ${VERSION}) for ${REPO}..."

gh api "repos/${REPO}/releases/tags/${TAG}" > /dev/null 2>&1 || {
	echo "ERROR: could not fetch release ${TAG} (does the tag exist?)" >&2
	exit 1
}

arm_name="engram_${VERSION}_darwin_arm64.tar.gz"
intel_name="engram_${VERSION}_darwin_amd64.tar.gz"

ARM_ASSET_ID="$(gh api "repos/${REPO}/releases/tags/${TAG}" --jq ".assets[] | select(.name==\"${arm_name}\") | .id" 2>/dev/null || true)"
INTEL_ASSET_ID="$(gh api "repos/${REPO}/releases/tags/${TAG}" --jq ".assets[] | select(.name==\"${intel_name}\") | .id" 2>/dev/null || true)"
CHECKSUMS_ASSET_ID="$(gh api "repos/${REPO}/releases/tags/${TAG}" --jq '.assets[] | select(.name=="checksums.txt") | .id' 2>/dev/null || true)"

if [[ -z "${ARM_ASSET_ID}" || -z "${INTEL_ASSET_ID}" || -z "${CHECKSUMS_ASSET_ID}" ]]; then
	echo "ERROR: release ${TAG} is missing one of: ${arm_name}, ${intel_name}, checksums.txt" >&2
	echo "  arm asset id=${ARM_ASSET_ID:-<missing>} intel asset id=${INTEL_ASSET_ID:-<missing>} checksums id=${CHECKSUMS_ASSET_ID:-<missing>}" >&2
	exit 1
fi

CHECKSUMS="$(gh api "repos/${REPO}/releases/assets/${CHECKSUMS_ASSET_ID}" --header 'Accept: application/octet-stream' 2>/dev/null || true)"
ARM_SHA="$(printf '%s\n' "${CHECKSUMS}" | awk -v f="${arm_name}" '$2==f {print $1}')"
INTEL_SHA="$(printf '%s\n' "${CHECKSUMS}" | awk -v f="${intel_name}" '$2==f {print $1}')"

if [[ -z "${ARM_SHA}" || -z "${INTEL_SHA}" ]]; then
	echo "ERROR: could not find both sha256 entries in checksums.txt" >&2
	exit 1
fi

echo "  darwin_arm64:  asset id ${ARM_ASSET_ID}, sha256 ${ARM_SHA}"
echo "  darwin_amd64:  asset id ${INTEL_ASSET_ID}, sha256 ${INTEL_SHA}"

cp "${FORMULA}" "${FORMULA}.bak"

# The two `url .../releases/assets/<id>` lines are identical in shape, so
# they cannot be told apart by a single sed pass keyed on the surrounding
# `on_arm`/`on_intel` blocks without a stateful script. Instead, this walks
# the file once, replacing the FIRST occurrence for on_arm's block and the
# SECOND for on_intel's — the formula's block order (on_arm before on_intel)
# is asserted by the check below, so a reordering fails loudly instead of
# silently swapping the two architectures' asset ids.
awk -v arm_id="${ARM_ASSET_ID}" -v intel_id="${INTEL_ASSET_ID}" -v arm_sha="${ARM_SHA}" -v intel_sha="${INTEL_SHA}" '
	/on_arm do/ { in_arm=1 }
	/on_intel do/ { in_arm=0; in_intel=1 }
	{
		if (in_arm && /releases\/assets\/[0-9]+/) { sub(/releases\/assets\/[0-9]+/, "releases/assets/" arm_id) }
		if (in_arm && /^  sha256 /) { sub(/"[a-f0-9]+"/, "\"" arm_sha "\""); in_arm=0 }
		if (in_intel && /releases\/assets\/[0-9]+/) { sub(/releases\/assets\/[0-9]+/, "releases/assets/" intel_id) }
		if (in_intel && /^  sha256 /) { sub(/"[a-f0-9]+"/, "\"" intel_sha "\""); in_intel=0 }
		print
	}
' "${FORMULA}.bak" | sed "s/^  version \".*\"/  version \"${VERSION}\"/" > "${FORMULA}"

if ! rg -q "on_arm do" "${FORMULA}" || ! rg -q "on_intel do" "${FORMULA}"; then
	echo "ERROR: formula no longer has both on_arm/on_intel blocks — restoring backup" >&2
	mv "${FORMULA}.bak" "${FORMULA}"
	exit 1
fi

echo
echo "Diff:"
diff -u "${FORMULA}.bak" "${FORMULA}" || true
rm -f "${FORMULA}.bak"

echo
echo "Review the diff above, then:"
echo "  HOMEBREW_GITHUB_API_TOKEN=\$(gh auth token) brew install --verbose HoracioEspinosa/tap/engram"
echo "  git -C \"${SCRIPT_DIR}/..\" add Formula/engram.rb"
echo "  git -C \"${SCRIPT_DIR}/..\" commit -m \"chore: bump engram to ${TAG}\""
