import QtQuick
import ".."

Rectangle {
    id: root

    property bool open: false
    property real strength: 0.45

    anchors.fill: parent
    color: Theme.withAlpha(Theme.colors.background, root.strength)
    opacity: root.open ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.normal
            easing.type: Theme.motion.enter
        }
    }
}
