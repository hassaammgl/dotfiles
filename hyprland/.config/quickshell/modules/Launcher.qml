import Quickshell
import QtQuick
import ".."

Rectangle {
    implicitWidth: 32
    implicitHeight: 32
    color: Colors.surface
    radius: 999

    BarButton {
        anchors.centerIn: parent
        icon: ""
        iconColor: Colors.accent
        onClicked: event => Quickshell.execDetached(["rofi", "-show", "drun"])
    }
}
