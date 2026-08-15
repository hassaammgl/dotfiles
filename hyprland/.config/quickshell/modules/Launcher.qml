import QtQuick
import ".."

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
