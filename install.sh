#!/bin/bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
INSTALL_DIR="$SCRIPT_DIR/install"

# shellcheck source=install/lib.sh
source "$INSTALL_DIR/lib.sh"

echo "=========================================="
echo "Starting system setup for dotfiles..."
echo "=========================================="
echo "   Dotfiles: $DOTFILES_DIR"

sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# shellcheck source=install/01-base.sh
source "$INSTALL_DIR/01-base.sh"
# shellcheck source=install/02-audio.sh
source "$INSTALL_DIR/02-audio.sh"
# shellcheck source=install/03-packages.sh
source "$INSTALL_DIR/03-packages.sh"
# shellcheck source=install/04-devtools.sh
source "$INSTALL_DIR/04-devtools.sh"
# shellcheck source=install/05-services.sh
source "$INSTALL_DIR/05-services.sh"
# shellcheck source=install/06-docker.sh
source "$INSTALL_DIR/06-docker.sh"
# shellcheck source=install/07-dotfiles.sh
source "$INSTALL_DIR/07-dotfiles.sh"

echo "=========================================="
echo "Setup finished."
echo ""
echo "Next steps:"
echo "  1. Reboot (docker group + PipeWire + NVIDIA/Intel drivers)"
echo "  2. Default shell: chsh -s \$(which fish)"
echo "  3. If Docker pulls were skipped, after reboot: sudo docker pull mysql:8 redis:7 postgres:16"
echo "  4. SearXNG (if Docker is up): http://localhost:8080"
echo "=========================================="
