#!/usr/bin/env bash

wall_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
current_link="$wall_dir/current"

mkdir -p "$wall_dir"

pick_random() {
    local img
    img=$(command find "$wall_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) | shuf -n 1)
    if [[ -z "$img" ]]; then
        notify-send -u critical "Wallpaper" "No images found in $wall_dir" &
        exit 1
    fi
    echo "$img"
}

set_with_awww() {
    local img="$1"
    if ! command -v awww &>/dev/null; then
        notify-send -u critical "Wallpaper" "awww not installed. Run: sudo pacman -S awww" &
        return 1
    fi
    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        awww-daemon >/dev/null 2>&1 &
        disown
        sleep 1
    fi
    awww img "$img" --transition-type fade --transition-duration 2
}

reload_themed_apps() {
    killall -SIGUSR2 waybar 2>/dev/null || true

    # makoctl can block on dbus — never hang the wallpaper script
    if pgrep -x mako >/dev/null 2>&1; then
        timeout 2 makoctl reload >/dev/null 2>&1 || {
            killall mako 2>/dev/null || true
            mako >/dev/null 2>&1 &
            disown
        }
    else
        mako >/dev/null 2>&1 &
        disown
    fi

    # Do not restart swayosd-server here — killing it breaks volume keys
    # until the next login. colors.css is picked up on the next OSD show.
}

apply_wallust() {
    local img="$1"
    if [[ "$img" =~ \.(gif|GIF)$ ]]; then
        return 0
    fi
    if ! command -v wallust &>/dev/null; then
        notify-send -u critical "Theme" "wallust not installed" &
        return 1
    fi
    if wallust run "$img"; then
        reload_themed_apps
    else
        notify-send -u critical "Theme" "wallust failed on $(basename "$img")" &
        return 1
    fi
}

set_wallpaper() {
    local img="$1"
    if [[ ! -f "$img" ]]; then
        notify-send -u critical "Wallpaper" "File not found: $img" &
        exit 1
    fi

    ln -sf "$img" "$current_link"

    set_with_awww "$img" || {
        notify-send -u critical "Wallpaper" "awww failed. Is awww installed?" &
        exit 1
    }

    apply_wallust "$img"
    notify-send "Wallpaper" "$(basename "$img")" &
}

case "${1:-random}" in
    random|next)
        set_wallpaper "$(pick_random)"
        ;;
    file)
        set_wallpaper "$2"
        ;;
    theme)
        if [[ -L "$current_link" || -f "$current_link" ]]; then
            apply_wallust "$(readlink -f "$current_link")"
            notify-send "Theme" "Synced to wallpaper colors" &
        else
            notify-send -u critical "Theme" "No current wallpaper set" &
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [random|next|file /path/to/img|theme]"
        exit 1
        ;;
esac
