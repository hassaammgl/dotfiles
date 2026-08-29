import QtQuick
import ".."

Item {
    id: root

    property real value: 0
    property bool dimmed: false

    signal applied(real value)

    readonly property real clamped: Math.max(0, Math.min(1, value))

    implicitHeight: 20
    implicitWidth: 200

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: Theme.r.pill
        color: Theme.colors.surfaceVariant

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(Theme.space.sm, parent.width * root.clamped)
            radius: Theme.r.pill
            color: root.dimmed ? Theme.colors.textMuted : Theme.colors.accent
        }

        Rectangle {
            width: 12
            height: 12
            radius: Theme.r.pill
            color: Theme.colors.text
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
