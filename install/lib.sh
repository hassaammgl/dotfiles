# shellcheck shell=bash

have() { pacman -Qq "$1" &>/dev/null; }

log() { echo "-> $*"; }

remove_conflicting() {
  local pkgs=()
  local p
  for p in "$@"; do
    have "$p" && pkgs+=("$p")
  done
  if ((${#pkgs[@]})); then
    echo "   Removing conflicting: ${pkgs[*]}"
    sudo pacman -Rdd --noconfirm "${pkgs[@]}" || true
  fi
}

pac_install() {
  if sudo pacman -S --needed --noconfirm "$@"; then
    return 0
  fi
  echo "   Batch install had errors — retrying packages one by one..."
  local p
  for p in "$@"; do
    sudo pacman -S --needed --noconfirm "$p" || echo "   SKIP (pacman): $p"
  done
}

aur_install() {
  if yay -S --needed --noconfirm "$@"; then
    return 0
  fi
  echo "   AUR batch had errors — retrying packages one by one..."
  local p
  for p in "$@"; do
    yay -S --needed --noconfirm "$p" || echo "   SKIP (aur): $p"
  done
}

# Read a package list file: one name per line, # comments allowed.
read_pkg_list() {
  local file="$1"
  local -n _out=$2
  local line
  _out=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    _out+=("$line")
  done <"$file"
}
