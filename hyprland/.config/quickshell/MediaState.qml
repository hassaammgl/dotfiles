pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    readonly property var player: {
        const vals = Mpris.players.values;
        let last = null;
        for (let i = 0; i < vals.length; i++) {
            const p = vals[i];
            if (!p)
                continue;
            if (p.isPlaying)
                return p;
            last = p;
        }
        return last;
    }

    readonly property var fallbackWin: {
        const tops = Hyprland.toplevels.values;
        for (let i = 0; i < tops.length; i++) {
            const t = tops[i];
            const ipc = t.lastIpcObject || {};
            const cls = `${t.class || ipc.class || ""}`.toLowerCase();
            const title = `${t.title || ipc.title || ""}`;
            if (cls === "mpv" || cls === "vlc" || cls === "celluloid" || cls.includes("mpv"))
                return {
                    "class": cls,
                    "title": title
                };
        }
        return null;
    }

    readonly property bool ready: player !== null || fallbackWin !== null
    readonly property bool playing: player ? player.isPlaying : fallbackWin !== null
    readonly property string title: {
        if (player)
            return player.trackTitle || "Unknown Title";
        if (fallbackWin) {
            let t = fallbackWin.title;
            t = t.replace(/\s+-\s+mpv\s*$/i, "").replace(/\s+-\s+VLC.*$/i, "");
            return t || fallbackWin.class;
        }
        return "no player";
    }
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string art: player ? (player.trackArtUrl || "") : ""
    readonly property string identity: {
        if (player)
            return player.identity || "player";
        if (fallbackWin)
            return fallbackWin.class || "player";
        return "";
    }
    readonly property real length: player && player.lengthSupported ? player.length : 0
    readonly property real position: player && player.positionSupported ? player.position : 0
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, position / length)) : 0

    function toggle(): void {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next(): void {
        if (player && player.canGoNext)
            player.next();
    }

    function prev(): void {
        if (player && player.canGoPrevious)
            player.previous();
    }

    function stop(): void {
        if (player && player.canControl)
            player.stop();
    }

    function raise(): void {
        if (player && player.canRaise)
            player.raise();
    }

    function seekRatio(r: real): void {
        if (!player || !player.canSeek || !player.positionSupported || length <= 0)
            return;
        player.position = Math.max(0, Math.min(length, r * length));
    }

    function fmt(secs: real): string {
        const s = Math.max(0, Math.floor(secs));
        const m = Math.floor(s / 60);
        const r = s % 60;
        return `${m}:${r < 10 ? "0" : ""}${r}`;
    }
}
