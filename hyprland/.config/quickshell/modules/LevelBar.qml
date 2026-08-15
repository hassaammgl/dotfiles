import QtQuick
import ".."

Item {
    id: root

    property real value: 0
    property string icon: ""
    property color iconColor: Colors.foreground
    property bool dimmed: false
    property bool dragging: false

    readonly property bool expanded: false
    readonly property real clamped: Math.max(0, Math.min(1, value))

    signal applied(real value)
    signal iconClicked

    implicitWidth: 24
    implicitHeight: 24

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: hover
    }

    function setFromPoint(x, y, w, h) {
        let next = BarState.vertical ? 1 - (y / Math.max(1, h)) : x / Math.max(1, w);
        next = Math.max(0, Math.min(1, next));
        root.applied(next);
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 24
        height: 24
        radius: 12
        color: hover.hovered ? Qt.rgba(1, 1, 1, 0.14) : "transparent"
        visible: BarState.vertical
    }

    Column {
        visible: BarState.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Text {
            text: root.icon
            color: root.iconColor
            font.family: Colors.fontFamily
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
                onWheel: event => {
                    const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
                    root.applied(Math.max(0, Math.min(1, root.clamped + step)));
                    event.accepted = true;
                }
            }
        }

        Rectangle {
            id: vTrack
            visible: false
            width: 6
            height: 52
            radius: 3
            color: Colors.color0
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height * root.clamped
                radius: 3
                color: root.dimmed ? Colors.color8 : Colors.color4
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: event => {
                    root.dragging = true;
                    root.setFromPoint(event.x, event.y, vTrack.width, vTrack.height);
                }
                onPositionChanged: event => {
                    if (pressed)
                        root.setFromPoint(event.x, event.y, vTrack.width, vTrack.height);
                }
                onReleased: root.dragging = false
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
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
                onWheel: event => {
                    const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
                    root.applied(Math.max(0, Math.min(1, root.clamped + step)));
                    event.accepted = true;
                }
            }
        }

        Rectangle {
            id: hTrack
            visible: false
            width: 72
            height: 6
            radius: 3
            color: Colors.color0
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * root.clamped
                radius: 3
                color: root.dimmed ? Colors.color8 : Colors.color4
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: event => {
                    root.dragging = true;
                    root.setFromPoint(event.x, event.y, hTrack.width, hTrack.height);
                }
                onPositionChanged: event => {
                    if (pressed)
                        root.setFromPoint(event.x, event.y, hTrack.width, hTrack.height);
                }
                onReleased: root.dragging = false
                onWheel: event => {
                    const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
                    root.applied(Math.max(0, Math.min(1, root.clamped + step)));
                    event.accepted = true;
                }
            }
        }
    }
}
