#!/usr/bin/env bash
# Cycle Quickshell bar edge: top -> bottom -> left -> right.

if ! pgrep -x qs >/dev/null 2>&1 && ! pgrep -x quickshell >/dev/null 2>&1; then
    qs -n >/dev/null 2>&1 &
    disown
    sleep 0.3
fi

qs ipc call bar cycleEdge
