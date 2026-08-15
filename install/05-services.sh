# shellcheck shell=bash

log "Enabling system services..."
sudo systemctl enable --now NetworkManager.service || true
sudo systemctl enable --now bluetooth.service || true
sudo systemctl enable --now cups.service || true

systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null \
  || systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

mkdir -p "$HOME/Videos" "$HOME/Pictures/Wallpapers" "$HOME/Pictures/WallpaperVideos" "$HOME/Downloads"

if command -v flatpak &>/dev/null; then
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
fi
