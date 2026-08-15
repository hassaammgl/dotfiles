import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel
import ".."

LevelBar {
    id: root

    property int raw: 0
    property int max: 1

    readonly property string device: backs.count > 0 ? backs.get(0, "fileName") : "intel_backlight"
    readonly property string briPath: `/sys/class/backlight/${device}/brightness`

    value: max > 0 ? raw / max : 0
    icon: {
        if (value < 0.25)
            return "󰃞";
        if (value < 0.7)
            return "󰃟";
        return "󰃠";
    }

    FolderListModel {
        id: backs
        folder: "file:///sys/class/backlight"
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
    }

    FileView {
        path: root.briPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.raw = parseInt(text().trim())
    }

    FileView {
        path: `/sys/class/backlight/${root.device}/max_brightness`
        onLoaded: root.max = parseInt(text().trim()) || 1
    }

    function write(next: real): void {
        if (root.max <= 0)
            return;
        const val = Math.round(Math.max(0.01, Math.min(1, next)) * root.max);
        root.raw = val;
        Quickshell.execDetached(["sh", "-c", `printf '%s' '${val}' > '${root.briPath}'`]);
    }

    onApplied: next => root.write(next)
}
