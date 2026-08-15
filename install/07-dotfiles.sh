# shellcheck shell=bash

log "Creating symlinks with GNU Stow..."
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Warning: $DOTFILES_DIR directory not found. Skipping Stow."
  return 0 2>/dev/null || true
fi

cd "$DOTFILES_DIR" || return 1

packages=(kitty wezterm tmux nvim hyprland btop fastfetch fish foot starship.toml cava lazygit lazydocker imv alacritty)
for pkg in "${packages[@]}"; do
  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    echo "   Skipping $pkg (no package directory)"
    continue
  fi
  echo "   Stowing $pkg..."
  stow --restow "$pkg" 2>/dev/null || {
    echo "   Conflict in $pkg — backing up existing files and retrying..."
    stow --no --verbose=2 "$pkg" 2>&1 | grep 'existing target' | awk '{print $NF}' | while read -r conflict; do
      [ -e "$HOME/$conflict" ] && mv "$HOME/$conflict" "$HOME/${conflict}.bak"
    done
    stow "$pkg" || echo "   SKIP stow $pkg"
  }
done

if [ -d "$HOME/.config/hypr/scripts" ]; then
  chmod +x "$HOME/.config/hypr/scripts"/*.sh 2>/dev/null || true
fi

log "Cloning Wallpapers to ~/Pictures/Wallpapers..."
WALLPAPER_REPO="https://github.com/hassaammgl/Wallpapers.git"
if [ -d "$HOME/Pictures/Wallpapers/.git" ]; then
  git -C "$HOME/Pictures/Wallpapers" pull || true
else
  if [ -d "$HOME/Pictures/Wallpapers" ] && [ "$(ls -A "$HOME/Pictures/Wallpapers")" ]; then
    mv "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Wallpapers.bak_$(date +%s)"
  fi
  git clone "$WALLPAPER_REPO" "$HOME/Pictures/Wallpapers" || true
fi

mkdir -p ~/.config
if [ -f "$DOTFILES_DIR/aliasis.bash" ]; then
  cp "$DOTFILES_DIR/aliasis.bash" ~/.config/aliasis.bash
  sed -i 's|source /usr/share/fzf/key-bindings.bash||' ~/.config/aliasis.bash
  sed -i 's|source /usr/share/fzf/completion.bash||' ~/.config/aliasis.bash
fi

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

add_to_bashrc() {
  grep -qxF "$1" ~/.bashrc || echo "$1" >>~/.bashrc
}
add_to_bashrc 'eval "$(starship init bash)"'
add_to_bashrc 'eval "$(zoxide init bash)"'
add_to_bashrc 'source ~/.config/aliasis.bash'
add_to_bashrc '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'
