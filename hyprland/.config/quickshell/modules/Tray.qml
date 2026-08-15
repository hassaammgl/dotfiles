import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import ".."

Rectangle {
    id: root

    visible: SystemTray.items.values.length > 0
    implicitWidth: BarState.vertical ? 32 : row.implicitWidth + 12
    implicitHeight: BarState.vertical ? col.implicitHeight + 12 : 32
    color: Colors.surface
    radius: 999

    component TrayIcon: Item {
        id: iconRoot
        required property var modelData

        implicitWidth: 20
        implicitHeight: 20

        Image {
            anchors.centerIn: parent
            width: 14
            height: 14
            source: iconRoot.modelData.icon
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 28
            sourceSize.height: 28
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
            onClicked: event => {
                if (event.button === Qt.LeftButton)
                    iconRoot.modelData.activate();
                else if (event.button === Qt.MiddleButton)
                    iconRoot.modelData.secondaryActivate();
                else if (iconRoot.modelData.hasMenu)
                    iconRoot.modelData.display(QsWindow.window, event.x, event.y);
            }
        }
    }

    Column {
        id: col
        visible: BarState.vertical
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items
            TrayIcon {}
        }
    }

    Row {
        id: row
        visible: !BarState.vertical
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items
            TrayIcon {}
        }
    }
}
