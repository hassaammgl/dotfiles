import QtQuick
import ".."

Item {
    id: root

    property real value: 0
    property string icon: ""
    property color iconColor: Colors.foreground
    property bool dimmed: false

    signal applied(real value)
    signal iconClicked

    readonly property real clamped: Math.max(0, Math.min(1, value))

    implicitWidth: BarState.vertical ? 28 : 108
    implicitHeight: BarState.vertical ? 84 : 22

    function setFromPoint(x, y, w, h) {
        let next = BarState.vertical ? 1 - (y / h) : x / w;
        next = Math.max(0, Math.min(1, next));
        root.applied(next);
    }

    Column {
        visible: BarState.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Text {
            text: root.icon
            color: root.iconColor
            font.family: Colors.fontFamily
            font.pixelSize: 13
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        Rectangle {
            id: vTrack
            width: 8
            height: 56
            radius: 4
            color: Colors.color0
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height * root.clamped
                radius: 4
                color: root.dimmed ? Colors.color8 : Colors.color4
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: event => root.setFromPoint(event.x, event.y, vTrack.width, vTrack.height)
                onPositionChanged: event => {
                    if (pressed)
                        root.setFromPoint(event.x, event.y, vTrack.width, vTrack.height);
                }
                onWheel: event => {
                    const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
                    root.applied(Math.max(0, Math.min(1, root.clamped + step)));
                    event.accepted = true;
                }
            }
        }
    }

    Row {
        visible: !BarState.vertical
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
            text: root.icon
            color: root.iconColor
            font.family: Colors.fontFamily
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        Rectangle {
            id: hTrack
            width: 72
            height: 8
            radius: 4
            color: Colors.color0
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * root.clamped
                radius: 4
                color: root.dimmed ? Colors.color8 : Colors.color4
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: event => root.setFromPoint(event.x, event.y, hTrack.width, hTrack.height)
                onPositionChanged: event => {
                    if (pressed)
                        root.setFromPoint(event.x, event.y, hTrack.width, hTrack.height);
                }
                onWheel: event => {
                    const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
                    root.applied(Math.max(0, Math.min(1, root.clamped + step)));
                    event.accepted = true;
                }
            }
        }
    }
}
