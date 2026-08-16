import QtQuick
import ".."

Item {
    id: root

    property real value: 0
    property bool dimmed: false

    signal applied(real value)

    readonly property real clamped: Math.max(0, Math.min(1, value))

    implicitHeight: 22
    implicitWidth: 200

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 8
        radius: 4
        color: Colors.color0

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(8, parent.width * root.clamped)
            radius: 4
            color: root.dimmed ? Colors.color8 : Colors.accent
        }

        Rectangle {
            width: 14
            height: 14
            radius: 7
            color: Colors.foreground
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(parent.width - width, parent.width * root.clamped - width / 2))
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: event => root.applied(Math.max(0, Math.min(1, event.x / Math.max(1, width))))
        onPositionChanged: event => {
            if (pressed)
                root.applied(Math.max(0, Math.min(1, event.x / Math.max(1, width))));
        }
        onWheel: event => {
            const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
            root.applied(Math.max(0, Math.min(1, root.clamped + step)));
            event.accepted = true;
        }
    }
}
