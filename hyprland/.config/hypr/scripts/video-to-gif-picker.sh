#!/usr/bin/env bash
# Pick a short clip from ~/Pictures/WallpaperVideos, convert to wallpaper GIF.
# After a successful convert, asks whether to delete the source video.

clip_dir="${WALLPAPER_CLIPS:-$HOME/Pictures/WallpaperVideos}"
convert="${HOME}/.config/hypr/scripts/video-to-gif.sh"

mkdir -p "$clip_dir"

kitty --title "video-to-gif" -e env CLIP_DIR="$clip_dir" CONVERT="$convert" bash -c '
  set +e
  clip_dir="$CLIP_DIR"
  convert="$CONVERT"

  mapfile -t videos < <(
    command find "$clip_dir" -maxdepth 1 -type f \( \
        -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" \
        -o -iname "*.mov" -o -iname "*.m4v" -o -iname "*.avi" \
      \) -print | LC_ALL=C sort
  )

  if [[ ${#videos[@]} -eq 0 ]]; then
    echo
    echo "  No videos in $clip_dir"
    echo "  Drop mp4/webm/mkv/mov clips here (max 20 seconds)."
    echo
    notify-send "Video → GIF" "Folder empty: $clip_dir" >/dev/null 2>&1
    read -r -p "  Press Enter to close…"
    exit 0
  fi

  preview_cmd="ffprobe -hide_banner -show_entries format=duration,size,format_name -of default=noprint_wrappers=1 {} 2>/dev/null | head -20"

  video=$(
    printf "%s\n" "${videos[@]}" \
      | fzf --preview "$preview_cmd" \
            --preview-window right:40% \
            --prompt "Clip → GIF > " \
            --header "Enter convert · Esc cancel  |  longer clips trimmed to 20s"
  ) || exit 0
  [[ -n "$video" ]] || exit 0

  echo
  echo "Converting: $(basename "$video")"
  echo
  "$convert" "$video"
  status=$?
  echo

  if [[ $status -ne 0 ]]; then
    echo "Convert failed — source video kept."
    read -r -p "Press Enter to close…"
    exit "$status"
  fi

  echo "GIF saved to ~/Pictures/Wallpapers/"
  echo
  read -r -p "Delete source video? [y/N] " ans
  if [[ "$ans" =~ ^[yY]([eE][sS])?$ ]]; then
    rm -f -- "$video" && echo "Deleted $(basename "$video")"
    notify-send "Video → GIF" "Deleted source: $(basename "$video")" >/dev/null 2>&1
  else
    echo "Kept $(basename "$video")"
  fi
  echo
  read -r -p "Press Enter to close…"
'
