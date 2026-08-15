# shellcheck shell=bash

log "Setting up development environments..."

if [ ! -d "$HOME/.nvm" ]; then
  echo "   Installing NVM & Node.js..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install node
  nvm use node
fi

if [ ! -d "$HOME/.bun" ]; then
  echo "   Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
fi

if ! command -v rustc &>/dev/null; then
  echo "   Installing Rust & Cargo..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Distro CLI — cargo tree-sitter-cli often fails on clang/llvm.
if ! command -v tree-sitter &>/dev/null; then
  echo "   Installing tree-sitter-cli from pacman..."
  pac_install tree-sitter tree-sitter-cli
fi
export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"
