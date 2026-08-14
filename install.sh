#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"

echo "=========================================="
echo "🚀 Starting System Setup for Dotfiles..."
echo "=========================================="
echo "   Dotfiles: $DOTFILES_DIR"

# 1. Ask for sudo password upfront
sudo -v

# Keep sudo alive until script finishes
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

echo "-> Updating system repositories..."
sudo pacman -Syu --noconfirm

echo "-> Installing base dependencies..."
sudo pacman -S --needed --noconfirm base-devel git stow curl wget unzip openssl

# 2. Install YAY (AUR Helper)
if ! command -v yay &>/dev/null; then
  echo "-> Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
  rm -rf /tmp/yay
else
  echo "-> yay is already installed."
fi

# 3. Define packages to install

PACMAN_PACKAGES=(
  # Terminals & shells
  "kitty"
  "wezterm"
  "alacritty"
  "foot"
  "tmux"
  "fish"
  "starship"

  # Editors & CLI
  "neovim"
  "fastfetch"
  "btop"
  "eza"
  "fzf"
  "zoxide"
  "bat"
  "ripgrep"
  "fd"
  "jq"
  "less"
  "direnv"
  "lazygit"
  "lazydocker"
  "chafa"
  "imagemagick"

  # Hyprland & Wayland Ecosystem
  "hyprland"
  "waybar"
  "mako"
  "rofi"
  "rofi-emoji"
  "fuzzel"
  "uwsm"
  "awww"
  "xdg-desktop-portal"
  "xdg-desktop-portal-hyprland"
  "xdg-desktop-portal-gtk"
  "xorg-xwayland"
  "polkit-gnome"
  "qt5-wayland"
  "qt6-wayland"
  "qt6ct"
  "kvantum"
  "grim"
  "slurp"
  "swappy"
  "hyprlock"
  "hyprpicker"
  "brightnessctl"
  "wf-recorder"
  "ffmpeg"
  "gifsicle"
  "cliphist"
  "ydotool"
  "wev"
  "gnome-keyring"
  "gammastep"
  "geoclue"
  "trash-cli"
  "libnotify"
  "wl-clipboard"

  # Theming / icons (Bibata cursor is AUR — see AUR_PACKAGES)
  "papirus-icon-theme"
  "adwaita-icon-theme"
  "gsettings-desktop-schemas"
  "dconf"

  # File managers & GUI helpers
  "nautilus"
  "nemo"
  "loupe"
  "yad"
  "zenity"
  "pavucontrol"
  "network-manager-applet"
  "webapp-manager"

  # Network / Bluetooth
  "networkmanager"
  "bluez"
  "bluez-utils"

  # Audio
  "pipewire"
  "pipewire-pulse"
  "pipewire-alsa"
  "pipewire-jack"
  "wireplumber"
  "playerctl"

  # Browsers & media
  "firefox"
  "vlc"
  "vlc-plugins-all"
  "mpv"
  "imv"
  "cava"
  "feh"

  # Dev / runtime
  "python"
  "python-pip"
  "uv"
  "git"
  "unzip"
  "ntfs-3g"

  # Fonts
  "ttf-victor-mono-nerd"
  "ttf-jetbrains-mono-nerd"
  "noto-fonts"
  "noto-fonts-emoji"
  "noto-fonts-cjk"

  # Containers & desktop extras
  "docker"
  "docker-compose"
  "flatpak"
  "gnome-software"
  "cups"
  "xdg-utils"
)

AUR_PACKAGES=(
  "swayosd-git"
  "wallust"
  "bibata-cursor-theme"
  "google-chrome"
  "brave-bin"
  "visual-studio-code-bin"
  "antigravity"
  "wlogout"
  "nwg-look"
  "ueberzugpp"
  "qps"
  "ani-cli"
)

sudo mkdir -p /mnt/codes

echo "-> Installing official packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

echo "-> Installing AUR packages..."
# Handle swayosd conflict if it exists
if pacman -Qs swayosd-git >/dev/null; then
  echo "   swayosd-git already installed."
elif pacman -Qs swayosd >/dev/null; then
  echo "   Removing conflicting swayosd package..."
  sudo pacman -Rns --noconfirm swayosd
fi
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# 4. Setup Development Environments (Node, Bun, Rust)
echo "-> Setting up Development Environments..."

# Install NVM and Node.js
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM & Node.js..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install node
  nvm use node
fi

# Install Bun
if [ ! -d "$HOME/.bun" ]; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
fi

# Install Rust & Cargo
if ! command -v rustc &>/dev/null; then
  echo "Installing Rust & Cargo..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

# Ensure cargo is on PATH for this session
# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# installing tree-sitter
cargo install tree-sitter-cli

# 5. Enable System Services
echo "-> Enabling System Services..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now docker.service
sudo systemctl enable --now cups.service
sudo usermod -aG docker "$USER"
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Ensure common media dirs exist (wf-recorder, wallpapers, etc.)
mkdir -p "$HOME/Videos" "$HOME/Pictures/Wallpapers" "$HOME/Pictures/WallpaperVideos" "$HOME/Downloads"

# pulling images (will not auto-start dbs)
# Use sudo — docker group only applies after re-login
echo "-> Pulling Docker images..."
sudo docker pull mysql:8
sudo docker pull redis:7
sudo docker pull postgres:16
sudo docker pull searxng/searxng:latest

# Setup Flatpak flathub repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 6. Initialize & Auto-start SearXNG
echo "-> Setting up SearXNG..."
mkdir -p "$HOME/searxng"
if [ ! -f "$HOME/searxng/settings.yml" ]; then
  echo "   Creating default SearXNG settings..."
  cat >"$HOME/searxng/settings.yml" <<EOF
use_default_settings: true
server:
    port: 8080
    bind_address: "0.0.0.0"
    secret_key: "$(openssl rand -hex 32)"
EOF
fi

# Start SearXNG with auto-restart on boot
if ! sudo docker ps -a --format '{{.Names}}' | grep -q '^searxng$'; then
  echo "   Starting SearXNG container..."
  sudo docker run -d \
    --name searxng \
    --restart always \
    -p 8080:8080 \
    -v "$HOME/searxng:/etc/searxng" \
    searxng/searxng:latest
fi

# 8. Stow Dotfiles
echo "-> Creating symlinks with GNU Stow..."
if [ -d "$DOTFILES_DIR" ]; then
  cd "$DOTFILES_DIR" || exit 1
  packages=(kitty wezterm tmux nvim hyprland btop fastfetch fish foot starship.toml cava lazygit lazydocker imv alacritty)
  for pkg in "${packages[@]}"; do
    if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
      echo "   Skipping $pkg (no package directory)"
      continue
    fi
    echo "   Stowing $pkg..."
    stow --restow "$pkg" 2>/dev/null || {
      echo "   Conflict detected in $pkg — attempting backup and retry..."
      stow --no --verbose=2 "$pkg" 2>&1 | grep 'existing target' | awk '{print $NF}' | while read -r conflict; do
        [ -e "$HOME/$conflict" ] && mv "$HOME/$conflict" "$HOME/${conflict}.bak"
      done
      stow "$pkg"
    }
  done

  # Hypr scripts must be executable after stow
  if [ -d "$HOME/.config/hypr/scripts" ]; then
    chmod +x "$HOME/.config/hypr/scripts"/*.sh 2>/dev/null || true
  fi

  # Clone Wallpapers from GitHub instead of stowing
  echo "   Cloning Wallpapers to ~/Pictures/Wallpapers..."
  WALLPAPER_REPO="https://github.com/hassaammgl/Wallpapers.git"

  if [ -d "$HOME/Pictures/Wallpapers/.git" ]; then
    echo "   Wallpapers repo already exists. Pulling latest changes..."
    git -C "$HOME/Pictures/Wallpapers" pull
  else
    if [ -d "$HOME/Pictures/Wallpapers" ] && [ "$(ls -A "$HOME/Pictures/Wallpapers")" ]; then
      echo "   ~/Pictures/Wallpapers exists and is not empty. Backing up..."
      mv "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Wallpapers.bak_$(date +%s)"
    fi
    git clone "$WALLPAPER_REPO" "$HOME/Pictures/Wallpapers"
  fi
else
  echo "Warning: $DOTFILES_DIR directory not found. Skipping Stow."
fi

# Copy aliases and fix bad fzf paths inside it
mkdir -p ~/.config
cp "$DOTFILES_DIR/aliasis.bash" ~/.config/aliasis.bash
sed -i 's|source /usr/share/fzf/key-bindings.bash||' ~/.config/aliasis.bash
sed -i 's|source /usr/share/fzf/completion.bash||' ~/.config/aliasis.bash

# Fix fzf to use actual install location (git or pacman)
cat >~/.fzf.bash <<'EOF'
if [ -d "$HOME/.fzf" ]; then
    export PATH="$HOME/.fzf/bin:$PATH"
    [[ -f "$HOME/.fzf/shell/key-bindings.bash" ]] && source "$HOME/.fzf/shell/key-bindings.bash"
    [[ -f "$HOME/.fzf/shell/completion.bash" ]] && source "$HOME/.fzf/shell/completion.bash"
elif [ -d "/usr/share/fzf" ]; then
    [[ -f "/usr/share/fzf/key-bindings.bash" ]] && source "/usr/share/fzf/key-bindings.bash"
    [[ -f "/usr/share/fzf/completion.bash" ]] && source "/usr/share/fzf/completion.bash"
fi
EOF

# Append to .bashrc idempotently
add_to_bashrc() {
  grep -qxF "$1" ~/.bashrc || echo "$1" >>~/.bashrc
}
add_to_bashrc 'eval "$(starship init bash)"'
add_to_bashrc 'eval "$(zoxide init bash)"'
add_to_bashrc 'source ~/.config/aliasis.bash'
add_to_bashrc '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'

echo "=========================================="
echo "✅ Setup completely finished!"
echo ""
echo "Next steps:"
echo "  1. Restart your system (required for docker group + pipewire)"
echo "  2. Set default shell: chsh -s \$(which fish)"
echo "  3. If Hyprland breaks: journalctl --user -b | grep -i hypr"
echo "  4. SearXNG is now AUTO-STARTING at http://localhost:8080"
echo "=========================================="
