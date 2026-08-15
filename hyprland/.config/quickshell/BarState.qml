pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property alias edge: adapter.edge
    property alias visible: adapter.visible

    readonly property bool vertical: edge === "left" || edge === "right"

    function cycle(): void {
        const order = ["top", "bottom", "left", "right"];
        const i = Math.max(0, order.indexOf(edge));
        edge = order[(i + 1) % order.length];
    }

    FileView {
        path: Quickshell.statePath("bar.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property string edge: "left"
            property bool visible: true
        }
    }
}
