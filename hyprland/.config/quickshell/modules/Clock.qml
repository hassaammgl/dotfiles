import QtQuick
import ".."

Rectangle {
    id: root

    property bool showDate: false

    implicitWidth: BarState.vertical ? 32 : layout.implicitWidth + 16
    implicitHeight: BarState.vertical ? layout.implicitHeight + 12 : 32
    color: Colors.surface
    radius: 999

    Column {
        id: layout
        visible: BarState.vertical
        anchors.centerIn: parent
        spacing: 2

        Text {
            visible: root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.weekday
            color: Colors.tertiary
            font.family: Colors.fontFamily
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            visible: root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.day
            color: Colors.tertiary
            font.family: Colors.fontFamily
            font.pixelSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            visible: root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
            width: 14
            height: 1
            color: Colors.tertiary
            opacity: 0.25
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.hour
            color: Colors.tertiary
            font.family: Colors.fontFamily
            font.pixelSize: 11
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.minute
            color: Colors.tertiary
            font.family: Colors.fontFamily
            font.pixelSize: 11
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.ampm.toLowerCase()
            color: Colors.tertiary
            font.family: Colors.fontFamily
            font.pixelSize: 9
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Text {
        visible: !BarState.vertical
        anchors.centerIn: parent
        text: root.showDate ? Time.altHorizontal : Time.horizontal
        color: Colors.tertiary
        font.family: Colors.fontFamily
        font.pixelSize: 12
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.showDate = !root.showDate
    }
}
