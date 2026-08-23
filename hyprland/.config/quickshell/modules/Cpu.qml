import Quickshell
import QtQuick
import ".."

BarButton {
    icon: "󰍛"
    active: OverlayState.dashboard
    onClicked: event => {
        if (event.button === Qt.RightButton)
            Quickshell.execDetached(["kitty", "btop"]);
        else
            OverlayState.toggleDashboard();
    }
}
