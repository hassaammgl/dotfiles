import Quickshell
import Quickshell.Hyprland
import QtQuick
import ".."

Rectangle {
    id: root

    readonly property var occupied: {
        const ids = {};
        for (const ws of Hyprland.workspaces.values) {
            const windows = ws.lastIpcObject?.windows;
            ids[ws.id] = windows === undefined ? true : windows > 0;
        }
        return ids;
    }

    readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    implicitWidth: BarState.vertical ? 32 : row.implicitWidth + 12
    implicitHeight: BarState.vertical ? col.implicitHeight + 12 : 32
    color: Colors.surface
    radius: 999

    component WsButton: Item {
        id: btn

        required property int index
        readonly property int wsId: index + 1
        readonly property bool focused: root.activeId === wsId
        readonly property bool exists: !!root.occupied[wsId]

        implicitWidth: 18
        implicitHeight: 18

        Text {
            anchors.centerIn: parent
            text: btn.focused || btn.exists ? "󰮯" : ""
            color: btn.focused ? Colors.accent : (btn.exists ? Colors.foreground : Colors.color8)
            opacity: btn.focused || btn.exists ? 1 : 0.45
            font.family: Colors.fontFamily
            font.pixelSize: btn.focused ? 12 : 10

            Behavior on font.pixelSize {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 160
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch(`workspace ${btn.wsId}`)
        }
    }

    Column {
        id: col
        visible: BarState.vertical
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: 5
            WsButton {}
        }
    }

    Row {
        id: row
        visible: !BarState.vertical
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: 5
            WsButton {}
        }
    }
}
