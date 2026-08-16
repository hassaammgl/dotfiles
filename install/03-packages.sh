# shellcheck shell=bash

sudo mkdir -p /mnt/codes

PACMAN_PACKAGES=()
read_pkg_list "$INSTALL_DIR/packages/pacman.txt" PACMAN_PACKAGES

log "Installing official packages (${#PACMAN_PACKAGES[@]})..."
pac_install "${PACMAN_PACKAGES[@]}"

AUR_PACKAGES=()
read_pkg_list "$INSTALL_DIR/packages/aur.txt" AUR_PACKAGES

log "Installing AUR packages (${#AUR_PACKAGES[@]})..."
aur_install "${AUR_PACKAGES[@]}"
