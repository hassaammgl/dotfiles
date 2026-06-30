#!/usr/bin/env bash
# Shows current network speed (up/down)

interface=$(ip route | awk '/^default/ {print $5}' | head -1)
[[ -z "$interface" ]] && { echo "󰤮"; exit 0; }

rx1=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
tx1=$(cat /sys/class/net/"$interface"/statistics/tx_bytes)
sleep 1
rx2=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
tx2=$(cat /sys/class/net/"$interface"/statistics/tx_bytes)

rx_diff=$((rx2 - rx1))
tx_diff=$((tx2 - tx1))

format_speed() {
    local bytes=$1
    if ((bytes > 1048576)); then
        echo "$(echo "scale=1; $bytes/1048576" | bc)MB/s"
    elif ((bytes > 1024)); then
        echo "$(echo "scale=1; $bytes/1024" | bc)KB/s"
    else
        echo "${bytes}B/s"
    fi
}

down=$(format_speed $rx_diff)
up=$(format_speed $tx_diff)

echo "$down $up"
