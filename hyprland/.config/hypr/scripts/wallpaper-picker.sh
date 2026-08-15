#!/usr/bin/env bash
# Opens the Quickshell wallpaper HUD (fallback: fzf in kitty).

if command -v qs >/dev/null 2>&1 && pgrep -x qs >/dev/null 2>&1; then
    qs ipc call wallpaper toggle
    exit 0
fi

wall_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
script="${WALLPAPER_SCRIPT:-$HOME/.config/hypr/scripts/wallpaper.sh}"

kitty --title "wallpaper-picker" -e env WALL_DIR="$wall_dir" WALL_SCRIPT="$script" bash -c '
  if command -v chafa >/dev/null 2>&1; then
    preview_cmd="chafa --symbols solid --size 40x25 {}"
  else
    preview_cmd="ls -la {}"
  fi

  command find "$WALL_DIR" \( -name .git -o -name current \) -prune -o -type f \( \
      -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
      -o -iname "*.webp" -o -iname "*.gif" \
    \) -print \
    | fzf --preview "$preview_cmd" \
          --preview-window right:40% \
          --prompt "Wallpaper > " \
          --header "↑↓ browse · type .gif · Enter select · Esc cancel" \
    | while IFS= read -r img; do
        [[ -n "$img" ]] || continue
        "$WALL_SCRIPT" file "$img"
      done
'
