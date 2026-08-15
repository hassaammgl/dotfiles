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
        icon: ""
        iconColor: Colors.color1
        onClicked: event => Quickshell.execDetached(["wlogout"])
    }
}
