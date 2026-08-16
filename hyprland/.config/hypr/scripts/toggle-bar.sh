#!/usr/bin/env bash
# Toggle the Quickshell bar.

if pgrep -x qs >/dev/null 2>&1 || pgrep -x quickshell >/dev/null 2>&1; then
    qs ipc call bar toggle
    exit 0
fi

qs -n >/dev/null 2>&1 &
disown
