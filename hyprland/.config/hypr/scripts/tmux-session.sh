#!/usr/bin/env bash
# Open/attach a tmux session (fzf picker when sessions exist)
set -euo pipefail

sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null || true)"

if [[ -n "${sessions}" ]]; then
  choice="$(
    printf '%s\n+ new session\n' "${sessions}" \
      | fzf --reverse --height=100% --header='tmux sessions' \
          --prompt='session> ' || true
  )"
  [[ -z "${choice}" ]] && exit 0

  if [[ "${choice}" == "+ new session" ]]; then
    name="$(fzf --reverse --height=100% --print-query --prompt='new name> ' </dev/null | head -1 || true)"
    name="${name:-main}"
    exec tmux new-session -s "${name}"
  fi

  exec tmux attach-session -t "${choice}"
fi

exec tmux new-session -A -s main
