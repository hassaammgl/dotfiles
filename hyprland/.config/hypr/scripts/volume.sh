#!/usr/bin/env bash
# Volume control with SwayOSD when available, wpctl fallback otherwise.
set -euo pipefail

step="${VOLUME_STEP:-10}"
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
        via_osd --output-volume "+${step}" && exit 0
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "${step}%+"
        ;;
    lower)
        via_osd --output-volume "-${step}" && exit 0
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${step}%-"
        ;;
    mute)
        via_osd --output-volume mute-toggle && exit 0
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    mic)
        via_osd --input-volume mute-toggle && exit 0
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    *)
        echo "Usage: $0 {raise|lower|mute|mic}" >&2
        exit 1
        ;;
esac
