#!/usr/bin/env bash
# First-frame JPEG thumbs for the video → GIF overlay.
set -euo pipefail

cache="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/gif-thumbs"
mkdir -p "$cache"

command -v ffmpeg >/dev/null 2>&1 || exit 0

for src in "$@"; do
    [[ -f "$src" ]] || continue
    dest="$cache/$(basename "$src").jpg"
    if [[ -f "$dest" && "$dest" -nt "$src" ]]; then
        continue
    fi
    ffmpeg -nostdin -y -hide_banner -loglevel error -ss 0.4 -i "$src" \
        -frames:v 1 -vf "scale=640:-2" "$dest" || true
done
