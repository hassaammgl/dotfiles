import Quickshell
import QtQuick
import ".."

BarButton {
    icon: ""
    iconColor: Colors.color1
    onClicked: event => Quickshell.execDetached(["wlogout"])
}
