import QtQuick
import ".."

Capsule {
    implicitWidth: 36
    implicitHeight: 36

    BarButton {
        anchors.centerIn: parent
        icon: ""
        iconColor: Colors.color1
        onClicked: event => OverlayState.togglePower()
    }
}
