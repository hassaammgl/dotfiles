import QtQuick
import ".."

Item {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: Colors.foreground
    property bool active: false
    property bool compact: BarState.vertical

    signal clicked(mouse: var)
    signal wheel(delta: int)

    implicitWidth: BarState.vertical ? 32 : Math.max(32, row.implicitWidth + 10)
    implicitHeight: BarState.vertical ? Math.max(28, col.implicitHeight + 8) : 28

    Rectangle {
        anchors.fill: parent
        radius: 999
        color: root.active ? Colors.color4 : (mouse.containsMouse ? Colors.color15 : "transparent")
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
            font.pixelSize: 13
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            visible: root.label.length > 0
            text: root.label
            color: root.active ? Colors.background : Colors.foreground
            font.family: Colors.fontFamily
            font.pixelSize: 9
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
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: root.label.length > 0
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
