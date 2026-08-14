#!/usr/bin/env bash
# Convert a video into a looping wallpaper GIF (first 20 seconds, max 4MB).
set -euo pipefail

max_secs=20
slow=2
max_bytes=$((4 * 1024 * 1024))
wall_dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
apply=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [options] <video> [output.gif]

Any format ffmpeg can read (mp4, webm, mkv, mov, …).
Longer clips are trimmed to the first ${max_secs}s.
Output is capped at 4MB.

Options:
  --set         Set the GIF as wallpaper after converting
  -h, --help    Show this help

Default output: ${wall_dir}/<name>.gif
EOF
}

die() {
    echo "error: $*" >&2
    notify-send -u critical "Video → GIF" "$*" >/dev/null 2>&1 || true
    exit 1
}

bytes_of() { stat -c%s "$1"; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        --set) apply=1; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        -*) die "unknown option: $1" ;;
        *) break ;;
    esac
done

[[ $# -ge 1 ]] || { usage; exit 1; }
src="$1"
out="${2:-}"

command -v ffmpeg >/dev/null 2>&1 || die "ffmpeg not installed. Run: sudo pacman -S ffmpeg"
command -v ffprobe >/dev/null 2>&1 || die "ffprobe not installed. Run: sudo pacman -S ffmpeg"
[[ -f "$src" ]] || die "file not found: $src"

dur=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1)
[[ -n "$dur" && "$dur" != "N/A" ]] || \
    dur=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration \
        -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1)

dur_int=${dur%.*}
[[ "$dur_int" =~ ^[0-9]+$ ]] || dur_int=""

if [[ -z "$out" ]]; then
    mkdir -p "$wall_dir"
    base=$(basename "$src")
    out="$wall_dir/${base%.*}.gif"
fi
mkdir -p "$(dirname "$out")"

src_w=$(ffprobe -v error -select_streams v:0 -show_entries stream=width \
    -of default=noprint_wrappers=1:nokey=1 "$src" | head -1)
[[ "$src_w" =~ ^[0-9]+$ ]] || src_w=1920

palette=$(mktemp --suffix=.png)
cleanup() { rm -f "$palette"; }
trap cleanup EXIT

trim=(-t "$max_secs")
delay_cs() { echo $((100 * slow / $1)); }

encode() {
    local scale="$1" fps="$2" colors="$3"
    local filters="fps=${fps},setpts=${slow}*PTS,scale=${scale}:-1:flags=lanczos"

    ffmpeg -y -v error -i "$src" "${trim[@]}" \
        -vf "${filters},palettegen=max_colors=${colors}:stats_mode=diff" "$palette"
    ffmpeg -y -v error -i "$src" "${trim[@]}" -i "$palette" \
        -lavfi "${filters}[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" \
        -loop 0 "$out"
}

squeeze() {
    local fps="$1" colors="$2"
    local delay slim
    delay=$(delay_cs "$fps")
    command -v gifsicle >/dev/null 2>&1 || return 0
    local lossy
    for lossy in 40 70 100 140 180; do
        (( $(bytes_of "$out") <= max_bytes )) && return 0
        slim=$(mktemp --suffix=.gif)
        gifsicle -O3 --lossy="$lossy" --colors "$colors" --delay "$delay" -o "$slim" "$out"
        mv -f "$slim" "$out"
    done
}

if [[ -n "$dur_int" && "$dur_int" -gt "$max_secs" ]]; then
    echo "Trimming $(basename "$src") (${dur_int}s → ${max_secs}s), cap 4MB"
else
    echo "Converting $(basename "$src"), cap 4MB"
fi

# Prefer sharpness; drop width/fps/colors only if still over 4MB.
ok=0
for preset in "1080 10 128" "960 8 128" "800 8 96" "720 8 64" "640 6 48"; do
    set -- $preset
    scale=$1 fps=$2 colors=$3
    (( src_w < scale )) && scale=$src_w
    echo "  try ${scale}px  ${fps}fps  ${colors} colors"
    encode "$scale" "$fps" "$colors"
    squeeze "$fps" "$colors"
    if (( $(bytes_of "$out") <= max_bytes )); then
        ok=1
        break
    fi
done

[[ "$ok" -eq 1 ]] || die "could not fit GIF under 4MB"

size=$(du -h "$out" | cut -f1)
echo "Wrote $out ($size)"
notify-send "Video → GIF" "$(basename "$out")  •  ${size}" >/dev/null 2>&1 || true

if [[ "$apply" -eq 1 ]]; then
    "$HOME/.config/hypr/scripts/wallpaper.sh" file "$out"
fi
