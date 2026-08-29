pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property real cpuPct: Host.cpuPct
    readonly property var corePcts: Host.corePcts
    readonly property real memPct: Host.memPct
    readonly property real swapPct: Host.swapPct
    readonly property string memLabel: Host.memLabel
    readonly property string swapLabel: Host.swapLabel
    readonly property real diskPct: Host.diskPct
    readonly property string diskLabel: Host.diskLabel
    readonly property string loadLabel: Host.loadLabel
    readonly property string uptimeLabel: Host.uptimeLabel
    readonly property string hostLabel: Host.hostLabel
    readonly property real downBps: Host.downBps
    readonly property real upBps: Host.upBps
    readonly property var procs: Host.procs

    function fmtBytes(n: real): string {
        return Host.fmtBytes(n);
    }

    function fmtSpeed(bps: real): string {
        return Host.fmtSpeed(bps);
    }
}
