#!/usr/bin/env bash
# fzf: switch tmux pane (all sessions)
set -euo pipefail

target="$(
  tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}' 2>/dev/null \
    | fzf --reverse --header='panes' \
    || true
)"

[[ -z "${target}" ]] && exit 0
id="$(echo "${target}" | awk '{print $1}')"
tmux switch-client -t "${id}"
tmux select-pane -t "${id}"
