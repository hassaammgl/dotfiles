#!/usr/bin/env bash
# Volume control — Quickshell OSD, wpctl fallback.
set -euo pipefail

step="${VOLUME_STEP:-10}"
action="${1:-}"

via_qs() {
    command -v qs >/dev/null 2>&1 || return 1
    pgrep -x qs >/dev/null 2>&1 || return 1
    qs ipc call osd "$1" >/dev/null 2>&1
}

case "$action" in
    raise)
        via_qs volumeUp && exit 0
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "${step}%+"
        ;;
    lower)
        via_qs volumeDown && exit 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${step}%-"
        ;;
    mute)
        via_qs volumeMute && exit 0
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    mic)
        via_qs micMute && exit 0
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    *)
        echo "Usage: $0 {raise|lower|mute|mic}" >&2
        exit 1
        ;;
esac
