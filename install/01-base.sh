# shellcheck shell=bash

log "Updating system..."
sudo pacman -Syu --noconfirm

log "Installing base dependencies..."
pac_install base-devel git stow curl wget unzip openssl

if ! command -v yay &>/dev/null; then
  log "Installing yay..."
  rm -rf /tmp/yay
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (
    cd /tmp/yay
    makepkg -si --noconfirm
  )
  rm -rf /tmp/yay
else
  log "yay is already installed."
fi
