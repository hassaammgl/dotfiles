import QtQuick
import ".."

Item {
    id: root

    property bool alt: false

    implicitWidth: BarState.vertical ? 32 : label.implicitWidth + 8
    implicitHeight: BarState.vertical ? label.implicitHeight + 12 : 28

    Text {
        id: label
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        color: Colors.foreground
        font.family: Colors.fontFamily
        font.pixelSize: BarState.vertical ? 11 : 12
        text: {
            if (BarState.vertical)
                return root.alt ? Time.altVertical : Time.vertical;
            return root.alt ? Time.altHorizontal : Time.horizontal;
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.alt = !root.alt
    }
}
