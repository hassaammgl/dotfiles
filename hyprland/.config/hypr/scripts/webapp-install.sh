#!/usr/bin/env bash
# Install a website as a desktop app (URL + icon image).
# Usage:
#   webapp-install.sh "App Name" "https://example.com" /path/to/icon.png
#   webapp-install.sh --remove "App Name"
set -euo pipefail

apps_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
icons_dir="${XDG_DATA_HOME:-$HOME/.local/share}/icons/webapps"
mkdir -p "$apps_dir" "$icons_dir"

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

pick_browser() {
    local b
    for b in brave google-chrome-stable chromium firefox; do
        if command -v "$b" &>/dev/null; then
            echo "$b"
            return 0
        fi
    done
    return 1
}

remove_app() {
    local name="$1"
    local id
    id="$(slugify "$name")"
    rm -f "$apps_dir/webapp-${id}.desktop"
    rm -f "$icons_dir/${id}".{png,jpg,jpeg,webp,svg,ico}
    update-desktop-database "$apps_dir" 2>/dev/null || true
    echo "Removed desktop app: $name"
}

if [[ "${1:-}" == "--remove" ]]; then
    [[ -n "${2:-}" ]] || { echo "Usage: $0 --remove \"App Name\"" >&2; exit 1; }
    remove_app "$2"
    exit 0
fi

if [[ $# -lt 3 ]]; then
    cat <<EOF >&2
Usage: $0 "App Name" "https://example.com" /path/to/icon.png
       $0 --remove "App Name"

Creates a launcher in ~/.local/share/applications that opens the site
in an app window (Brave/Chrome/Chromium --app, or Firefox).

Tip: for a GUI, install and run: webapp-manager
EOF
    exit 1
fi

name="$1"
url="$2"
icon_src="$3"

[[ -f "$icon_src" ]] || { echo "Icon not found: $icon_src" >&2; exit 1; }
[[ "$url" =~ ^https?:// ]] || { echo "URL must start with http:// or https://" >&2; exit 1; }

browser="$(pick_browser)" || {
    echo "No supported browser found (brave, chrome, chromium, firefox)." >&2
    exit 1
}

id="$(slugify "$name")"
ext="${icon_src##*.}"
ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
case "$ext" in
    png|jpg|jpeg|webp|svg|ico) ;;
    *) ext="png" ;;
esac

icon_dst="$icons_dir/${id}.${ext}"
cp -f "$icon_src" "$icon_dst"

desktop="$apps_dir/webapp-${id}.desktop"

case "$browser" in
    firefox)
        exec_line="$browser --new-window \"$url\""
        ;;
    *)
        exec_line="$browser --app=\"$url\" --name=\"$name\" --class=\"WebApp-$id\""
        ;;
esac

cat >"$desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Comment=Web app: $url
Exec=$exec_line
Icon=$icon_dst
Terminal=false
StartupNotify=true
Categories=Network;WebBrowser;
StartupWMClass=WebApp-$id
EOF

chmod +x "$desktop"
update-desktop-database "$apps_dir" 2>/dev/null || true

echo "Installed: $name"
echo "  Desktop: $desktop"
echo "  Icon:    $icon_dst"
echo "  Browser: $browser"
echo "Find it in rofi / app launcher, or run: gtk-launch webapp-${id}"
