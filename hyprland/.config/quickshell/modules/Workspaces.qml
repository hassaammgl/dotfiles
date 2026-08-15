import Quickshell
import Quickshell.Hyprland
import QtQuick
import ".."

Item {
    id: root

    implicitWidth: BarState.vertical ? 32 : row.implicitWidth
    implicitHeight: BarState.vertical ? col.implicitHeight : 28

    readonly property var occupied: {
        const ids = {};
        for (const ws of Hyprland.workspaces.values) {
            if (ws.id > 0)
                ids[ws.id] = true;
        }
        return ids;
    }

    component WsButton: Item {
        id: btn

        required property int wsId
        readonly property bool focused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
        readonly property bool exists: !!root.occupied[wsId]

        implicitWidth: 22
        implicitHeight: 22

        Rectangle {
            anchors.centerIn: parent
            width: btn.focused ? 18 : 8
            height: btn.focused ? 18 : 8
            radius: 999
            color: btn.focused ? Colors.color4 : (btn.exists ? Colors.color8 : Colors.color0)
            opacity: btn.focused || btn.exists ? 1 : 0.35

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            visible: btn.focused
            anchors.centerIn: parent
            text: btn.wsId === 10 ? "0" : `${btn.wsId}`
            color: Colors.background
            font.family: Colors.fontFamily
            font.pixelSize: 9
            font.bold: true
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
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Repeater {
            model: 5
            WsButton {
                required property int index
                wsId: index + 1
            }
        }
    }

    Row {
        id: row
        visible: !BarState.vertical
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: 5
            WsButton {
                required property int index
                wsId: index + 1
            }
        }
    }
}
