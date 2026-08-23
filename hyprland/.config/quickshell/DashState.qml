pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuPct: 0
    property var corePcts: []
    property real memPct: 0
    property real swapPct: 0
    property string memLabel: "—"
    property string swapLabel: "—"
    property real diskPct: 0
    property string diskLabel: "—"
    property string loadLabel: "—"
    property string uptimeLabel: "—"
    property string hostLabel: ""
    property real downBps: 0
    property real upBps: 0
    property var procs: []

    property real _lastIdle: 0
    property real _lastTotal: 0
    property var _lastCoreIdle: []
    property var _lastCoreTotal: []
    property real _lastRx: -1
    property real _lastTx: -1
    property real _lastAt: 0

    function fmtBytes(n: real): string {
        if (n < 1024)
            return `${Math.round(n)}B`;
        if (n < 1048576)
            return `${(n / 1024).toFixed(1)}K`;
        if (n < 1073741824)
            return `${(n / 1048576).toFixed(1)}M`;
        return `${(n / 1073741824).toFixed(1)}G`;
    }

    function fmtSpeed(bps: real): string {
        return `${fmtBytes(bps)}/s`;
    }

    Process {
        id: poll
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                let section = "";
                const coresNow = [];
                const coreIdle = [];
                const coreTotal = [];
                let memTotal = 0, memAvail = 0, swapTotal = 0, swapFree = 0;
                let rx = -1, tx = -1;
                const nextProcs = [];

                const lines = text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i];
                    if (line === "===CPU===") {
                        section = "cpu";
                        continue;
                    }
                    if (line === "===MEM===") {
                        section = "mem";
                        continue;
                    }
                    if (line === "===DISK===") {
                        section = "disk";
                        continue;
                    }
                    if (line === "===NET===") {
                        section = "net";
                        continue;
                    }
                    if (line === "===META===") {
                        section = "meta";
                        continue;
                    }
                    if (line === "===PROCS===") {
                        section = "procs";
                        continue;
                    }
                    if (!line.length)
                        continue;

                    if (section === "cpu") {
                        const p = line.trim().split(/\s+/);
                        if (p[0] === "cpu" || p[0].startsWith("cpu")) {
                            let total = 0;
                            for (let j = 1; j < p.length; j++)
                                total += parseInt(p[j], 10) || 0;
                            const idle = (parseInt(p[4], 10) || 0) + (parseInt(p[5], 10) || 0);
                            if (p[0] === "cpu") {
                                if (root._lastTotal > 0) {
                                    const dT = total - root._lastTotal;
                                    const dI = idle - root._lastIdle;
                                    if (dT > 0)
                                        root.cpuPct = Math.max(0, Math.min(100, Math.round(100 * (1 - dI / dT))));
                                }
                                root._lastTotal = total;
                                root._lastIdle = idle;
                            } else {
                                coreTotal.push(total);
                                coreIdle.push(idle);
                            }
                        }
                    } else if (section === "mem") {
                        const m = line.match(/^(\w+):\s+(\d+)/);
                        if (!m)
                            continue;
                        const k = m[1];
                        const v = parseInt(m[2], 10);
                        if (k === "MemTotal")
                            memTotal = v;
                        else if (k === "MemAvailable")
                            memAvail = v;
                        else if (k === "SwapTotal")
                            swapTotal = v;
                        else if (k === "SwapFree")
                            swapFree = v;
                    } else if (section === "disk") {
                        const p = line.trim().split(/\s+/);
                        if (p.length >= 5 && p[0] !== "Filesystem") {
                            const pct = parseInt(String(p[4]).replace("%", ""), 10);
                            if (!isNaN(pct)) {
                                root.diskPct = pct;
                                root.diskLabel = `${p[2]} / ${p[1]}  (${pct}%)`;
                            }
                        }
                    } else if (section === "net") {
                        const p = line.trim().split(/\s+/);
                        if (p.length >= 2) {
                            rx = parseInt(p[0], 10);
                            tx = parseInt(p[1], 10);
                        }
                    } else if (section === "meta") {
                        if (line.startsWith("load "))
                            root.loadLabel = line.slice(5);
                        else if (line.startsWith("up "))
                            root.uptimeLabel = line.slice(3);
                        else if (line.startsWith("host "))
                            root.hostLabel = line.slice(5);
                    } else if (section === "procs") {
                        // pid user cpu mem rss command...
                        const m = line.match(/^\s*(\d+)\s+(\S+)\s+([\d.]+)\s+([\d.]+)\s+(\d+)\s+(.*)$/);
                        if (!m)
                            continue;
                        nextProcs.push({
                            "pid": m[1],
                            "user": m[2],
                            "cpu": parseFloat(m[3]),
                            "mem": parseFloat(m[4]),
                            "rss": parseInt(m[5], 10),
                            "cmd": m[6]
                        });
                    }
                }

                // per-core
                if (coreTotal.length) {
                    const prevI = root._lastCoreIdle;
                    const prevT = root._lastCoreTotal;
                    const pcts = [];
                    for (let c = 0; c < coreTotal.length; c++) {
                        if (prevT.length === coreTotal.length && prevT[c] > 0) {
                            const dT = coreTotal[c] - prevT[c];
                            const dI = coreIdle[c] - prevI[c];
                            pcts.push(dT > 0 ? Math.max(0, Math.min(100, Math.round(100 * (1 - dI / dT)))) : 0);
                        } else {
                            pcts.push(0);
                        }
                    }
                    root.corePcts = pcts;
                    root._lastCoreIdle = coreIdle;
                    root._lastCoreTotal = coreTotal;
                }

                if (memTotal > 0) {
                    const used = memTotal - memAvail;
                    root.memPct = Math.round(100 * used / memTotal);
                    root.memLabel = `${root.fmtBytes(used * 1024)} / ${root.fmtBytes(memTotal * 1024)}`;
                }
                if (swapTotal > 0) {
                    const used = swapTotal - swapFree;
                    root.swapPct = Math.round(100 * used / swapTotal);
                    root.swapLabel = `${root.fmtBytes(used * 1024)} / ${root.fmtBytes(swapTotal * 1024)}`;
                } else {
                    root.swapPct = 0;
                    root.swapLabel = "none";
                }

                const now = Date.now();
                if (rx >= 0 && tx >= 0 && root._lastRx >= 0 && root._lastAt > 0) {
                    const dt = Math.max(0.2, (now - root._lastAt) / 1000);
                    root.downBps = Math.max(0, (rx - root._lastRx) / dt);
                    root.upBps = Math.max(0, (tx - root._lastTx) / dt);
                }
                if (rx >= 0) {
                    root._lastRx = rx;
                    root._lastTx = tx;
                    root._lastAt = now;
                }

                root.procs = nextProcs;
            }
        }
    }

    Timer {
        interval: 1000
        running: OverlayState.dashboard
        repeat: true
        triggeredOnStart: true
        onTriggered: poll.exec([
            "bash",
            "-c",
            `echo '===CPU==='; cat /proc/stat | head -n 33
echo '===MEM==='; grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):' /proc/meminfo
echo '===DISK==='; df -h / | tail -1
echo '===NET==='; iface=$(ip route get 1.1.1.1 2>/dev/null | awk '/dev/{print $5; exit}'); [ -z "$iface" ] && iface=$(ls /sys/class/net | grep -v lo | head -1); echo "$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0) $(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)"
echo '===META==='; echo "load $(cut -d' ' -f1-3 /proc/loadavg)"; echo -n 'up '; uptime -p 2>/dev/null | sed 's/^up //' || awk '{print int($1/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime; echo "host $(hostname)"
echo '===PROCS==='; ps -eo pid=,user=,%cpu=,%mem=,rss=,comm= --sort=-%cpu | head -n 18`
        ])
    }
}
