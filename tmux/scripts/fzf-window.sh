#!/usr/bin/env bash
# fzf: switch tmux window (all sessions)
set -euo pipefail

target="$(
  tmux list-windows -a -F '#{session_name}:#{window_index}:#{window_name}#{window_active|*}' 2>/dev/null \
    | fzf --reverse --header='windows' \
    || true
)"

[[ -z "${target}" ]] && exit 0
# session:index:name → session:index
session_window="$(echo "${target}" | cut -d: -f1-2)"
tmux switch-client -t "${session_window}"
