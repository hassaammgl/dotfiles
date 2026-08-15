import QtQuick
import ".."

Item {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: Colors.foreground
    property bool active: false
    property bool labelOnHover: false
    readonly property bool hovered: mouse.containsMouse

    signal clicked(mouse: var)
    signal wheel(delta: int)

    implicitWidth: BarState.vertical ? 28 : Math.max(28, row.implicitWidth + 8)
    implicitHeight: BarState.vertical ? Math.max(24, col.implicitHeight + 2) : 26

    Rectangle {
        anchors.centerIn: parent
        width: 24
        height: 24
        radius: 12
        color: root.active ? Colors.color4 : (root.hovered ? Qt.rgba(1, 1, 1, 0.14) : "transparent")
    }

    Column {
        id: col
        visible: BarState.vertical
        anchors.centerIn: parent
        spacing: 1

        Text {
            text: root.icon
            color: root.active ? Colors.background : root.iconColor
            font.family: Colors.fontFamily
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            visible: root.label.length > 0 && (!root.labelOnHover || root.hovered)
            text: root.label
            color: root.active ? Colors.background : Colors.foreground
            font.family: Colors.fontFamily
            font.pixelSize: 8
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Row {
        id: row
        visible: !BarState.vertical
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: root.icon
            color: root.active ? Colors.background : root.iconColor
            font.family: Colors.fontFamily
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: root.label.length > 0 && (!root.labelOnHover || root.hovered)
            text: root.label
            color: root.active ? Colors.background : Colors.foreground
            font.family: Colors.fontFamily
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }
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
