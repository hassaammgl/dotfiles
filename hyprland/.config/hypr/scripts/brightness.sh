#!/usr/bin/env bash
# Brightness — Quickshell OSD, brightnessctl fallback.
set -euo pipefail

action="${1:-}"

via_qs() {
    command -v qs >/dev/null 2>&1 || return 1
    pgrep -x qs >/dev/null 2>&1 || return 1
    qs ipc call osd "$1" >/dev/null 2>&1
}

case "$action" in
    raise)
        via_qs brightnessUp && exit 0
        brightnessctl set 5%+
        ;;
    lower)
        via_qs brightnessDown && exit 0
        brightnessctl set 5%-
        ;;
    *)
        echo "Usage: $0 {raise|lower}" >&2
        exit 1
        ;;
esac
