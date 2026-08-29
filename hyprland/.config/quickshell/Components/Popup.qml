import QtQuick
import ".."

Item {
    id: root

    default property alias content: body.data
    property bool open: false
    property int panelW: 320
    property int extraX: 0

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: extraX + panelW
    opacity: open ? 1 : 0
    x: open ? 0 : -16

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.normal
            easing.type: Theme.motion.enter
        }
    }

    Behavior on x {
        NumberAnimation {
            duration: Theme.motion.normal
            easing.type: Theme.motion.enter
        }
    }

    Card {
        id: body
        anchors.left: parent.left
        anchors.leftMargin: extraX
        anchors.top: parent.top
        anchors.topMargin: Theme.space.lg
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.space.lg
        width: panelW
        clip: true
    }
}
