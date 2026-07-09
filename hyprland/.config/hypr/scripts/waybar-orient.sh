#!/usr/bin/env bash

CONFIG="$HOME/.config/waybar/config.jsonc"
CONFIG_HORIZONTAL="$HOME/.config/waybar/config-horizontal.jsonc"
CONFIG_VERTICAL="$HOME/.config/waybar/config-vertical.jsonc"
CSS_HORIZONTAL="$HOME/.config/waybar/style-horizontal.css"
CSS_VERTICAL="$HOME/.config/waybar/style-vertical.css"
CSS_ACTIVE="$HOME/.config/waybar/style.css"

current=$(grep -oP '"position":\s*"\K[^"]+' "$CONFIG")

case "$current" in
    top)    next="bottom" ;;
    bottom) next="left"   ;;
    left)   next="right"  ;;
    right)  next="top"    ;;
    *)      next="top"    ;;
esac

if [[ "$next" == "left" || "$next" == "right" ]]; then
    cp "$CONFIG_VERTICAL" "$CONFIG"
    cp "$CSS_VERTICAL" "$CSS_ACTIVE"
else
    cp "$CONFIG_HORIZONTAL" "$CONFIG"
    cp "$CSS_HORIZONTAL" "$CSS_ACTIVE"
fi

sed -i "s/\"position\": \"[^\"]*\"/\"position\": \"$next\"/" "$CONFIG"

pkill -x waybar
pkill -f "waybar\.sh"
~/.config/hypr/scripts/waybar.sh &