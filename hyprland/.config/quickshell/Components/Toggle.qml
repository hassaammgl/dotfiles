import QtQuick
import ".."

Rectangle {
    id: root

    property bool checked: false

    implicitWidth: 42
    implicitHeight: 22
    radius: Theme.r.pill
    color: root.checked ? Theme.colors.accent : Theme.colors.surfaceVariant

    Rectangle {
        width: 16
        height: 16
        radius: Theme.r.pill
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 3 : 3
        color: Theme.colors.text

        Behavior on x {
            NumberAnimation {
                duration: Theme.motion.fast
                easing.type: Theme.motion.enter
            }
        }
    }

    signal clicked

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
