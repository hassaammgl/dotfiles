import Quickshell
import QtQuick
import ".."

BarButton {
    icon: ""
    iconColor: Colors.color4
    onClicked: event => Quickshell.execDetached(["rofi", "-show", "drun"])
}
