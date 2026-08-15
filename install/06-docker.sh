# shellcheck shell=bash

if ! have docker; then
  echo "   docker package missing — skipping Docker setup."
  return 0 2>/dev/null || true
fi

log "Setting up Docker..."
sudo systemctl enable docker.socket || true
sudo systemctl enable --now docker.service || sudo systemctl enable --now docker.socket || true
sudo usermod -aG docker "$USER" || true

echo "   Waiting for Docker daemon..."
docker_ready=0
for _ in $(seq 1 30); do
  if sudo docker info >/dev/null 2>&1; then
    docker_ready=1
    break
  fi
  sleep 1
done

if [[ "$docker_ready" -ne 1 ]]; then
  echo "   Docker daemon not ready — skipping image pulls. Re-run after reboot."
  return 0 2>/dev/null || true
fi

log "Pulling Docker images..."
sudo docker pull mysql:8 || echo "   SKIP docker pull mysql:8"
sudo docker pull redis:7 || echo "   SKIP docker pull redis:7"
sudo docker pull postgres:16 || echo "   SKIP docker pull postgres:16"
sudo docker pull searxng/searxng:latest || echo "   SKIP docker pull searxng"

log "Setting up SearXNG..."
mkdir -p "$HOME/searxng"
if [ ! -f "$HOME/searxng/settings.yml" ]; then
  cat >"$HOME/searxng/settings.yml" <<EOF
use_default_settings: true
server:
    port: 8080
    bind_address: "0.0.0.0"
    secret_key: "$(openssl rand -hex 32)"
EOF
fi

if ! sudo docker ps -a --format '{{.Names}}' | grep -q '^searxng$'; then
  echo "   Starting SearXNG container..."
  sudo docker run -d \
    --name searxng \
    --restart always \
    -p 8080:8080 \
    -v "$HOME/searxng:/etc/searxng" \
    searxng/searxng:latest || echo "   SKIP SearXNG container"
fi
