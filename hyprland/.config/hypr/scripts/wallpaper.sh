#!/usr/bin/env bash

wall_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/wallust"
conf_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
current_link="$wall_dir/current"

mkdir -p "$cache_dir" "$conf_dir" "$wall_dir"

pick_random() {
    local img
    img=$(find "$wall_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) | shuf -n 1)
    if [[ -z "$img" ]]; then
        notify-send -u critical "Wallpaper" "No images found in $wall_dir"
        exit 1
    fi
    echo "$img"
}

set_with_awww() {
    local img="$1"
    if ! command -v awww &>/dev/null; then
        notify-send -u critical "Wallpaper" "awww not installed. Run: sudo pacman -S awww"
        return 1
    fi
    # ensure daemon is running
    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        awww-daemon &
        sleep 1
    fi
    awww img "$img" --transition-type fade --transition-duration 2
}

set_with_hyprpaper() {
    return 1
}

set_wallpaper() {
    local img="$1"
    ln -sf "$img" "$current_link"

    # try awww first, fallback to hyprpaper
    set_with_awww "$img" || set_with_hyprpaper "$img" || {
        notify-send -u critical "Wallpaper" "No wallpaper daemon found. Install awww (pacman -S awww) or hyprpaper."
        exit 1
    }

    # wallust colors (skip gifs)
    if [[ ! "$img" =~ \.gif$ ]]; then
        wallust run "$img" -p 2>/dev/null &
    fi

    # reload waybar
    sleep 0.5
    killall -SIGUSR2 waybar 2>/dev/null
    pkill -RTMIN+1 waybar 2>/dev/null

    notify-send "Wallpaper" "$(basename "$img")"
}

case "${1:-random}" in
    random|next)
        img=$(pick_random)
        set_wallpaper "$img"
        ;;
    file)
        set_wallpaper "$2"
        ;;
    *)
        echo "Usage: $0 [random|next|file /path/to/img]"
        exit 1
        ;;
esac
