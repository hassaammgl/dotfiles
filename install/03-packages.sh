# shellcheck shell=bash

sudo mkdir -p /mnt/codes

PACMAN_PACKAGES=()
read_pkg_list "$INSTALL_DIR/packages/pacman.txt" PACMAN_PACKAGES

log "Installing official packages (${#PACMAN_PACKAGES[@]})..."
pac_install "${PACMAN_PACKAGES[@]}"

AUR_PACKAGES=()
read_pkg_list "$INSTALL_DIR/packages/aur.txt" AUR_PACKAGES

log "Installing AUR packages (${#AUR_PACKAGES[@]})..."
if have swayosd-git; then
  echo "   swayosd-git already installed."
elif have swayosd; then
  echo "   Removing conflicting swayosd..."
  sudo pacman -Rns --noconfirm swayosd || true
fi
aur_install "${AUR_PACKAGES[@]}"
