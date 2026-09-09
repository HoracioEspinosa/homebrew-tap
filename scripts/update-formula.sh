#!/usr/bin/env bash
#
# update-formula.sh — bump Formula/engram.rb to a new release of
# HoracioEspinosa/engram.
#
# The formula's download URL is derived from `version` alone, since the
# repository is public — nothing to resolve there. The one thing a version
# bump does not fix by itself is each darwin tarball's sha256, published in
# the release's own checksums.txt and never recomputed here. This script
# re-resolves those two checksums instead of hand-editing them.
#
# Usage:
#   bash scripts/update-formula.sh v1.20.1-cd.1
#
# Requires: curl. Prints a diff of Formula/engram.rb; does not commit.
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

command -v curl > /dev/null 2>&1 || { echo "ERROR: curl is not available" >&2; exit 1; }

VERSION="${TAG#v}"
echo "Resolving release ${TAG} (version ${VERSION}) for ${REPO}..."

CHECKSUMS_URL="https://github.com/${REPO}/releases/download/${TAG}/checksums.txt"
CHECKSUMS="$(curl -sfL "${CHECKSUMS_URL}")" || {
	echo "ERROR: could not download ${CHECKSUMS_URL} (does the tag exist?)" >&2
	exit 1
}

arm_name="engram_${VERSION}_darwin_arm64.tar.gz"
intel_name="engram_${VERSION}_darwin_amd64.tar.gz"

ARM_SHA="$(printf '%s\n' "${CHECKSUMS}" | awk -v f="${arm_name}" '$2==f {print $1}')"
INTEL_SHA="$(printf '%s\n' "${CHECKSUMS}" | awk -v f="${intel_name}" '$2==f {print $1}')"

if [[ -z "${ARM_SHA}" || -z "${INTEL_SHA}" ]]; then
	echo "ERROR: could not find both sha256 entries in checksums.txt for ${arm_name} / ${intel_name}" >&2
	exit 1
fi

echo "  darwin_arm64:  sha256 ${ARM_SHA}"
echo "  darwin_amd64:  sha256 ${INTEL_SHA}"

cp "${FORMULA}" "${FORMULA}.bak"

# The two `sha256 "..."` lines are identical in shape, so they cannot be told
# apart by a single sed pass keyed on the surrounding on_arm/on_intel blocks
# without a stateful script. Instead, this walks the file once, replacing the
# FIRST sha256 line for on_arm's block and the SECOND for on_intel's — the
# formula's block order (on_arm before on_intel) is asserted by the check
# below, so a reordering fails loudly instead of silently swapping the two
# architectures' checksums.
awk -v arm_sha="${ARM_SHA}" -v intel_sha="${INTEL_SHA}" '
	/on_arm do/ { in_arm=1 }
	/on_intel do/ { in_arm=0; in_intel=1 }
	{
		if (in_arm && /^  sha256 /) { sub(/"[a-f0-9]+"/, "\"" arm_sha "\""); in_arm=0 }
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
echo "  brew install --verbose HoracioEspinosa/tap/engram"
echo "  git -C \"${SCRIPT_DIR}/..\" add Formula/engram.rb"
echo "  git -C \"${SCRIPT_DIR}/..\" commit -m \"chore: bump engram to ${TAG}\""
