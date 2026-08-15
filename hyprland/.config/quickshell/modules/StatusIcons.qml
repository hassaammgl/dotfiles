import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root

    implicitWidth: BarState.vertical ? 32 : icons.implicitWidth + 10
    implicitHeight: BarState.vertical ? icons.implicitHeight + 10 : 32
    color: Colors.surface
    radius: 999

    GridLayout {
        id: icons
        anchors.centerIn: parent
        columns: BarState.vertical ? 1 : 8
        rows: BarState.vertical ? 8 : 1
        flow: BarState.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rowSpacing: 2
        columnSpacing: 2

        Bluetooth {}
        Network {}
        Audio {}
        Brightness {}
        Cpu {}
        Battery {}
    }
}
