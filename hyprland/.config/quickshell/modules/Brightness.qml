import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import ".."

Item {
    id: root

    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    property bool ignoreClick: false
    property int raw: 0
    property int max: 1

    readonly property string device: backs.count > 0 ? backs.get(0, "fileName") : "intel_backlight"
    readonly property string briPath: `/sys/class/backlight/${device}/brightness`
    readonly property real level: max > 0 ? raw / max : 0

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

    BarButton {
        id: btn
        anchors.centerIn: parent
        active: pop.visible
        icon: {
            if (root.level < 0.25)
                return "󰃞";
            if (root.level < 0.7)
                return "󰃟";
            return "󰃠";
        }
        onClicked: event => {
            if (root.ignoreClick)
                return;
            pop.visible = !pop.visible;
        }
        onWheel: delta => {
            const step = delta > 0 ? 0.05 : -0.05;
            root.write(root.level + step);
        }
    }

    PopupWindow {
        id: pop

        visible: false
        color: "transparent"
        implicitWidth: 280
        implicitHeight: 118
        grabFocus: true

        anchor {
            item: root
            edges: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            gravity: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            adjustment: PopupAdjustment.Slide
            margins.left: 10
            margins.right: 10
            margins.top: 10
            margins.bottom: 10
        }

        HyprlandFocusGrab {
            active: pop.visible
            windows: [pop]
            onCleared: {
                pop.visible = false;
                root.ignoreClick = true;
                Qt.callLater(() => {
                    root.ignoreClick = false;
                });
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Colors.background
            border.width: 1
            border.color: Colors.color0
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Brightness"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    Text {
                        text: `${Math.round(root.level * 100)}%`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }
                }

                PopSlider {
                    Layout.fillWidth: true
                    value: root.level
                    onApplied: next => root.write(next)
                }
            }
        }
    }
}
