#!/usr/bin/env bash
# Re-fetches the vendored CV fonts under cv/fonts/. The resulting files are
# committed to git — this script exists to document their provenance and
# make a refresh reproducible, not as part of the day-to-day build.
#
# Sources:
#   Source Sans Pro   — https://github.com/adobe-fonts/source-sans (Pro release)
#   Roboto            — https://github.com/googlefonts/roboto
#   Font Awesome 7    — https://github.com/FortAwesome/Font-Awesome (7.x)
# All three families are OFL 1.1.
#
# Note: the website uses a separate type stack (DM Sans / Kanit / DM Mono)
# loaded from Google Fonts at runtime, not from this directory.

set -euo pipefail

DEST="$(cd "$(dirname "$0")/.." && pwd)/cv/fonts"
mkdir -p "$DEST"

fetch() {
    local url="$1" dest="$2"
    curl -sSLfo "$DEST/$dest" "$url"
    echo "  ✓ $dest"
}

echo "Source Sans Pro (OTF):"
SSP_BASE="https://github.com/adobe-fonts/source-sans/raw/refs/tags/3.052R/OTF"
for f in SourceSansPro-Regular.otf SourceSansPro-It.otf \
         SourceSansPro-Light.otf SourceSansPro-LightIt.otf \
         SourceSansPro-Semibold.otf SourceSansPro-SemiboldIt.otf \
         SourceSansPro-Bold.otf SourceSansPro-BoldIt.otf; do
    fetch "${SSP_BASE}/${f}" "$f"
done

echo "Roboto (TTF):"
RB_BASE="https://github.com/googlefonts/roboto/raw/refs/heads/main/src/hinted"
for f in Roboto-Regular.ttf Roboto-Italic.ttf \
         Roboto-Light.ttf Roboto-LightItalic.ttf \
         Roboto-Medium.ttf Roboto-MediumItalic.ttf \
         Roboto-Bold.ttf Roboto-BoldItalic.ttf; do
    fetch "${RB_BASE}/${f}" "$f"
done

# Font Awesome 7 Free (OTF) is required by brilliant-CV's icons. If this URL
# rots, grab the "Desktop" zip from https://fontawesome.com/download, unzip,
# and drop the otfs/ files into cv/fonts/.
echo "Font Awesome 7 Free (OTF):"
FA_BASE="https://github.com/FortAwesome/Font-Awesome/raw/refs/heads/7.x/otfs"
for f in "Font Awesome 7 Brands-Regular-400.otf" "Font Awesome 7 Free-Regular-400.otf" "Font Awesome 7 Free-Solid-900.otf"; do
    fetch "${FA_BASE}/${f// /%20}" "$f"
done

echo
echo "Done. $(ls "$DEST" | wc -l) files in $DEST"
