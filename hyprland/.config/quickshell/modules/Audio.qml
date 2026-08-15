import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import ".."

LevelBar {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    readonly property bool muted: ready ? sink.audio.muted : false

    value: ready ? sink.audio.volume : 0
    dimmed: muted
    icon: {
        if (muted || !ready || value === 0)
            return "";
        if (value < 0.35)
            return "";
        if (value < 0.7)
            return "";
        return "";
    }
    iconColor: muted ? Colors.color8 : Colors.foreground

    PwObjectTracker {
        objects: root.sink !== null ? [root.sink] : []
    }

    onIconClicked: {
        if (root.ready)
            root.sink.audio.muted = !root.sink.audio.muted;
    }

    onApplied: next => {
        if (!root.ready)
            return;
        root.sink.audio.muted = false;
        root.sink.audio.volume = next;
    }
}
