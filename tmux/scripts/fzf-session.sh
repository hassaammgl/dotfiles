#!/usr/bin/env bash
# fzf: switch tmux session
set -euo pipefail

session="$(
  {
    tmux list-sessions -F '#{session_name}' 2>/dev/null || true
    echo '+ new session'
  } | fzf --reverse --header='tmux sessions' || true
)"

[[ -z "${session}" ]] && exit 0

if [[ "${session}" == '+ new session' ]]; then
  name="$(echo | fzf --reverse --print-query --prompt='name> ' --header='new session name' | head -1 || true)"
  name="${name:-main}"
  tmux new-session -d -s "${name}"
  tmux switch-client -t "${name}"
  exit 0
fi

tmux switch-client -t "${session}"
