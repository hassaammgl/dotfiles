import Quickshell
import QtQuick
import qs.state

BarButton {
    icon: "󰄛"
    active: WidgetState.enabled
    onClicked: event => {
        if (event.button === Qt.RightButton)
            WidgetState.cycleCharacter();
        else if (event.button === Qt.MiddleButton)
            WidgetState.resetAll();
        else
            WidgetState.toggle();
    }
}
