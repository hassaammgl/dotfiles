#!/usr/bin/env bash
# Brightness with SwayOSD when available, brightnessctl fallback otherwise.
set -euo pipefail

action="${1:-}"

ensure_osd() {
    if ! pgrep -x swayosd-server >/dev/null 2>&1; then
        command -v swayosd-server >/dev/null 2>&1 || return 1
        swayosd-server >/dev/null 2>&1 &
        disown
        sleep 0.15
    fi
    pgrep -x swayosd-server >/dev/null 2>&1
}

via_osd() {
    ensure_osd || return 1
    swayosd-client "$@" >/dev/null 2>&1
}

case "$action" in
    raise)
        via_osd --brightness raise && exit 0
        brightnessctl set 5%+
        ;;
    lower)
        via_osd --brightness lower && exit 0
        brightnessctl set 5%-
        ;;
    *)
        echo "Usage: $0 {raise|lower}" >&2
        exit 1
        ;;
esac
