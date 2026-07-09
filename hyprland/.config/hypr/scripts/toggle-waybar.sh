#!/usr/bin/env bash

if pgrep -x waybar > /dev/null 2>&1; then
    pkill -x waybar
    pkill -f "waybar\.sh"
else
    ~/.config/hypr/scripts/waybar.sh &
fi
