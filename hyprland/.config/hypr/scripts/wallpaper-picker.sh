#!/usr/bin/env bash

wall_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"

kitty --title "wallpaper-picker" -e bash -c '
  wall_dir="$HOME/Pictures/Wallpapers"
  script="$HOME/.config/hypr/scripts/wallpaper.sh"

  if command -v chafa &>/dev/null; then
    preview_cmd="chafa --symbols solid --size 40x25 {}"
  else
    preview_cmd="ls -la {}"
  fi

  find "$wall_dir" -maxdepth 1 -type f \( -iname '\''*.jpg'\'' -o -iname '\''*.png'\'' -o -iname '\''*.jpeg'\'' -o -iname '\''*.webp'\'' -o -iname '\''*.gif'\'' \) \
    | fzf --preview "$preview_cmd" \
          --preview-window right:40% \
          --prompt "Wallpaper > " \
          --header "↑↓ browse · Enter select · Esc cancel" \
    | xargs -r -I{} "$script" file "{}"
'
