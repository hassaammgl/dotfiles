import QtQuick
import qs.theme
import qs.state

Capsule {
    implicitWidth: 36
    implicitHeight: 36

    BarButton {
        anchors.centerIn: parent
        icon: ""
        iconColor: Colors.accent
        onClicked: event => OverlayState.toggleLauncher()
    }
}
