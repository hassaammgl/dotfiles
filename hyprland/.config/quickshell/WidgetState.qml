pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property alias enabled: adapter.enabled
    property alias character: adapter.character
    property alias showClock: adapter.showClock
    property alias showCalendar: adapter.showCalendar
    property alias showStats: adapter.showStats
    property alias showMedia: adapter.showMedia
    property alias showMascot: adapter.showMascot
    property alias showGreeting: adapter.showGreeting
    property alias corner: adapter.corner
    property alias scale: adapter.scale

    readonly property var characters: ["session.gif", "media.gif", "dashboard.gif", "empty.png"]

    function toggle(): void {
        enabled = !enabled;
    }

    function cycleCharacter(): void {
        const list = root.characters;
        const i = Math.max(0, list.indexOf(character));
        character = list[(i + 1) % list.length];
    }

    function cycleCorner(): void {
        const order = ["bottom-right", "bottom-left", "top-right", "top-left"];
        const i = Math.max(0, order.indexOf(corner));
        corner = order[(i + 1) % order.length];
    }

    function resetAll(): void {
        showClock = true;
        showCalendar = true;
        showStats = true;
        showMedia = true;
        showMascot = true;
        showGreeting = true;
        enabled = true;
    }

    FileView {
        path: Quickshell.statePath("widgets.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property bool enabled: true
            property string character: "session.gif"
            property bool showClock: true
            property bool showCalendar: true
            property bool showStats: true
            property bool showMedia: true
            property bool showMascot: true
            property bool showGreeting: true
            property string corner: "bottom-right"
            property real scale: 1.0
        }
    }
}
