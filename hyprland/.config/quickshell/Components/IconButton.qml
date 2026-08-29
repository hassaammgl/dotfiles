import QtQuick
import ".."

Item {
    id: root

    property string icon: ""
    property string tooltip: ""
    property color iconColor: Theme.colors.text
    property bool active: false
    property bool compact: true

    signal clicked(mouse: var)
    signal wheel(delta: int)

    implicitWidth: Theme.bar.item
    implicitHeight: Theme.bar.item

    Rectangle {
        anchors.centerIn: parent
        width: Theme.bar.item - 4
        height: Theme.bar.item - 4
        radius: Theme.r.sm
        color: root.active ? Theme.colors.accentSoft : (mouse.containsMouse ? Theme.colors.surfaceElevated : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.active ? Theme.colors.accent : root.iconColor
        font.family: Theme.font.icon
        font.pixelSize: Theme.bar.icon
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => root.clicked(event)
        onWheel: event => {
            root.wheel(event.angleDelta.y);
            event.accepted = true;
        }
    }
}
