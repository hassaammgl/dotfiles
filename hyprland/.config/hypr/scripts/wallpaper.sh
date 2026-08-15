#!/usr/bin/env bash
# Set wallpaper via awww and sync wallust colors across the desktop.

wall_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
current_link="$wall_dir/current"
lock_file="${XDG_RUNTIME_DIR:-/tmp}/wallpaper.apply.lock"
css="$HOME/.config/waybar/colors.css"
quiet="${WALLPAPER_QUIET:-0}"

mkdir -p "$wall_dir"

# Close inherited lock fds so daemons (swayosd/mako) cannot pin the lock forever.
spawn() {
    (
        local fd
        for fd in $(seq 3 20); do
            eval "exec ${fd}>&-" 2>/dev/null || true
        done
        exec "$@" </dev/null >/dev/null 2>&1
    ) &
    disown
}

notify() {
    local urgency="low"
    if [[ "$1" == "critical" || "$1" == "normal" || "$1" == "low" ]]; then
        urgency="$1"
        shift
    fi
    [[ "$quiet" == "1" ]] && return 0
    spawn notify-send -u "$urgency" "$@"
}

acquire_lock() {
    exec 9>"$lock_file"
    if ! flock -n 9; then
        exit 0
    fi
}

release_lock() {
    flock -u 9 2>/dev/null || true
    exec 9>&- 2>/dev/null || true
}

# Strip leftover quotes from broken pickers, then follow symlinks.
resolve_image() {
    local raw="$1"
    [[ -n "$raw" ]] || return 1
    raw="${raw#\'}"
    raw="${raw%\'}"
    raw="${raw#\"}"
    raw="${raw%\"}"
    local real
    real=$(readlink -f -- "$raw" 2>/dev/null || true)
    [[ -n "$real" && -f "$real" ]] || return 1
    printf '%s\n' "$real"
}

list_wallpapers() {
    command find "$wall_dir" \( -name .git -o -name current \) -prune -o -type f \( \
        -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.webp' -o -iname '*.gif' \
    \) -print
}

pick_random() {
    local exclude="${1:-}"
    local img
    img=$(list_wallpapers | {
        if [[ -n "$exclude" ]]; then
            grep -Fxv -- "$exclude" || true
        else
            cat
        fi
    } | shuf -n 1)
    if [[ -z "$img" ]]; then
        notify critical "Wallpaper" "No images found in $wall_dir"
        return 1
    fi
    printf '%s\n' "$img"
}

ensure_awww() {
    if ! command -v awww &>/dev/null; then
        notify critical "Wallpaper" "awww not installed. Run: sudo pacman -S awww"
        return 1
    fi
    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        spawn awww-daemon
    fi
    local i
    for i in $(seq 1 25); do
        awww query >/dev/null 2>&1 && return 0
        sleep 0.2
    done
    notify critical "Wallpaper" "awww-daemon failed to start"
    return 1
}

wait_for_proc() {
    local proc="$1"
    local i
    for i in $(seq 1 20); do
        pgrep -x "$proc" >/dev/null 2>&1 && return 0
        sleep 0.15
    done
    return 1
}

css_hex() {
    local name="$1"
    sed -n "s/.*@define-color ${name} #\([0-9A-Fa-f]\{6\}\).*/\1/p" "$css" | head -1
}

# First still frame for GIFs — wallust cannot palette an animation.
theme_source() {
    local img="$1"
    local ext="${img##*.}"
    ext="${ext,,}"
    if [[ "$ext" != "gif" ]]; then
        printf '%s\n' "$img"
        return 0
    fi
    if ! command -v magick &>/dev/null; then
        notify critical "Theme" "imagemagick needed for GIF palettes"
        return 1
    fi
    local frame="${XDG_CACHE_HOME:-$HOME/.cache}/wallust/gif-frame.png"
    mkdir -p "$(dirname "$frame")"
    magick "${img}[0]" "$frame" || return 1
    printf '%s\n' "$frame"
}

reload_hypr_colors() {
    [[ -f "$css" ]] || return 0
    local active inactive fg bg
    active=$(css_hex color4)
    inactive=$(css_hex color8)
    fg=$(css_hex foreground)
    bg=$(css_hex background)
    [[ -n "$active" && -n "$inactive" && -n "$fg" && -n "$bg" ]] || return 0

    hyprctl eval "hl.config({
        general = { col = {
            active_border = \"rgba(${active}e6)\",
            inactive_border = \"rgba(${inactive}11)\",
        }},
        group = {
            col = {
                border_active = \"rgba(${active}e6)\",
                border_inactive = \"rgba(${inactive}11)\",
                border_locked_active = \"rgba(${active}e6)\",
                border_locked_inactive = \"rgba(${inactive}11)\",
            },
            groupbar = {
                text_color = \"rgb(${fg})\",
                col = {
                    active = \"rgba(${active}d4)\",
                    inactive = \"rgba(${inactive}d4)\",
                    locked_active = \"rgba(${active}d4)\",
                    locked_inactive = \"rgba(${bg}d4)\",
                },
            },
        },
    })" >/dev/null 2>&1 || true
}

reload_themed_apps() {
    killall -SIGUSR2 waybar 2>/dev/null || true
    # Quickshell Colors.qml watches ~/.cache/wallust/quickshell.json

    if pgrep -x mako >/dev/null 2>&1; then
        timeout 2 makoctl reload >/dev/null 2>&1 || true
    fi

    # Do not restart swayosd — killing it used to leak the wallpaper lock
    # and break volume keys. colors.css is read on the next OSD popup.

    reload_hypr_colors
}

apply_wallust() {
    local img="$1"
    if ! command -v wallust &>/dev/null; then
        notify critical "Theme" "wallust not installed"
        return 1
    fi
    local src
    if ! src=$(theme_source "$img"); then
        return 1
    fi
    # -s: don't inject OSC sequences into open terminals (breaks nvim/tmux)
    if wallust run -s "$src"; then
        return 0
    else
        notify critical "Theme" "wallust failed on $(basename "$img")"
        return 1
    fi
}

set_wallpaper() {
    local img
    if ! img=$(resolve_image "$1"); then
        notify critical "Wallpaper" "File not found: $1"
        return 1
    fi

    # Always point at the real file — never ln current -> current
    ln -sfn "$img" "$current_link"

    if ! ensure_awww; then
        return 1
    fi
    if ! awww img "$img" --transition-type fade --transition-duration 2; then
        notify critical "Wallpaper" "awww failed on $(basename "$img")"
        return 1
    fi

    apply_wallust "$img" || true
    notify "Wallpaper" "$(basename "$img")"
}

finish() {
    release_lock
    reload_themed_apps
}

restore() {
    quiet=1
    ensure_awww || true
    local img=""
    img=$(resolve_image "$current_link" 2>/dev/null || true)
    if [[ -n "$img" ]]; then
        set_wallpaper "$img"
    else
        local pick
        pick=$(pick_random) || return 1
        set_wallpaper "$pick"
    fi
}

case "${1:-random}" in
    random)
        acquire_lock
        set_wallpaper "$(pick_random)" || { release_lock; exit 1; }
        finish
        ;;
    next)
        acquire_lock
        cur=$(resolve_image "$current_link" 2>/dev/null || true)
        nxt=$(pick_random "$cur" 2>/dev/null || pick_random) || { release_lock; exit 1; }
        set_wallpaper "$nxt" || { release_lock; exit 1; }
        finish
        ;;
    file)
        acquire_lock
        set_wallpaper "$2" || { release_lock; exit 1; }
        finish
        ;;
    theme)
        acquire_lock
        img=$(resolve_image "$current_link") || {
            release_lock
            notify critical "Theme" "No current wallpaper set"
            exit 1
        }
        apply_wallust "$img" || { release_lock; exit 1; }
        notify "Theme" "Synced to wallpaper colors"
        finish
        ;;
    restore)
        acquire_lock
        restore || { release_lock; exit 1; }
        finish
        ;;
    *)
        echo "Usage: $0 [random|next|file /path/to/img|theme|restore]"
        exit 1
        ;;
esac
