#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
out="${2:-}"
[[ -n "$mode" && -n "$out" ]] || exit 1
mkdir -p "$(dirname "$out")"

case "$mode" in
    full)
        grim "$out"
        ;;
    region)
        geom=$(slurp) || exit 2
        grim -g "$geom" "$out"
        ;;
    window)
        json=$(hyprctl activewindow -j 2>/dev/null) || exit 1
        geom=$(python3 -c 'import json,sys
w=json.load(sys.stdin)
if not w or "at" not in w or "size" not in w:
    raise SystemExit(1)
print(f"{int(w[\"at\"][0])},{int(w[\"at\"][1])} {int(w[\"size\"][0])}x{int(w[\"size\"][1])}")' <<<"$json")
        grim -g "$geom" "$out"
        ;;
    *)
        exit 1
        ;;
esac
