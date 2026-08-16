pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel

Singleton {
    id: root

    property bool visible: false
    property string kind: "volume"

    readonly property real volStep: 0.1
    readonly property real briStep: 0.05

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property real vol: ready ? sink.audio.volume : 0
    readonly property bool micReady: source !== null && source.ready && source.audio !== null
    readonly property bool micMuted: micReady ? source.audio.muted : false
    readonly property real micVol: micReady ? source.audio.volume : 0

    readonly property var sinks: {
        const out = [];
        for (const n of Pipewire.nodes.values) {
            if (n && n.isSink && !n.isStream)
                out.push(n);
        }
        return out;
    }

    property int rawBri: 0
    property int maxBri: 1
    readonly property string device: backs.count > 0 ? backs.get(0, "fileName") : "intel_backlight"
    readonly property real bri: maxBri > 0 ? rawBri / maxBri : 0

    readonly property real value: {
        if (kind === "brightness")
            return bri;
        if (kind === "mic")
            return micMuted ? 0 : micVol;
        return muted ? 0 : vol;
    }

    readonly property string volumeIcon: {
        if (muted || !ready || vol === 0)
            return "";
        if (vol < 0.35)
            return "";
        if (vol < 0.7)
            return "";
        return "";
    }

    readonly property string brightnessIcon: {
        if (bri < 0.25)
            return "󰃞";
        if (bri < 0.7)
            return "󰃟";
        return "󰃠";
    }

    readonly property string icon: {
        if (kind === "brightness")
            return brightnessIcon;
        if (kind === "mic")
            return micMuted ? "󰍭" : "󰍬";
        return volumeIcon;
    }

    readonly property bool dimmed: kind === "mic" ? micMuted : (kind === "volume" && muted)
    readonly property string percent: `${Math.round(value * 100)}%`

    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.sinks).filter(n => n)
    }

    FolderListModel {
        id: backs
        folder: "file:///sys/class/backlight"
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
    }

    FileView {
        id: briView
        path: `/sys/class/backlight/${root.device}/brightness`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.rawBri = parseInt(text().trim()) || 0
    }

    FileView {
        path: `/sys/class/backlight/${root.device}/max_brightness`
        onLoaded: root.maxBri = parseInt(text().trim()) || 1
    }

    Timer {
        id: hide
        interval: 1400
        onTriggered: root.visible = false
    }

    function show(kind: string): void {
        root.kind = kind;
        visible = true;
        hide.restart();
    }

    function nodeLabel(n: var): string {
        return n.nickname || n.description || n.name || "output";
    }

    function setVol(next: real, ping: bool): void {
        if (!ready)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, next));
        if (ping)
            show("volume");
    }

    function setMic(next: real, ping: bool): void {
        if (!micReady)
            return;
        source.audio.muted = false;
        source.audio.volume = Math.max(0, Math.min(1, next));
        if (ping)
            show("mic");
    }

    function setBri(next: real, ping: bool): void {
        const clamped = Math.max(0.01, Math.min(1, next));
        const pct = Math.round(clamped * 100);
        rawBri = Math.round(clamped * Math.max(1, maxBri));
        Quickshell.execDetached(["brightnessctl", "set", `${pct}%`]);
        if (ping)
            show("brightness");
        Qt.callLater(() => briView.reload());
    }

    function volumeUp(): void {
        setVol(vol + volStep, true);
    }

    function volumeDown(): void {
        setVol(vol - volStep, true);
    }

    function volumeMute(ping: bool): void {
        if (!ready)
            return;
        sink.audio.muted = !sink.audio.muted;
        if (ping)
            show("volume");
    }

    function micMute(ping: bool): void {
        if (!micReady)
            return;
        source.audio.muted = !source.audio.muted;
        if (ping)
            show("mic");
    }

    function brightnessUp(): void {
        setBri(bri + briStep, true);
    }

    function brightnessDown(): void {
        setBri(bri - briStep, true);
    }
}
