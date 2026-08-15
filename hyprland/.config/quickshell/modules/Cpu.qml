import Quickshell
import QtQuick
import ".."

BarButton {
    icon: "󰍛"
    onClicked: event => Quickshell.execDetached(["kitty", "btop"])
}
