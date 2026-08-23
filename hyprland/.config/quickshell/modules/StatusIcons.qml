import QtQuick
import QtQuick.Layouts
import ".."

Capsule {
    id: root

    implicitWidth: BarState.vertical ? 36 : icons.implicitWidth + 12
    implicitHeight: BarState.vertical ? icons.implicitHeight + 12 : 36
    clip: true

    GridLayout {
        id: icons
        anchors.centerIn: parent
        columns: BarState.vertical ? 1 : 9
        rows: BarState.vertical ? 9 : 1
        flow: BarState.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rowSpacing: 2
        columnSpacing: 2

        Bluetooth {}
        Network {}
        Audio {}
        Brightness {}
        Cpu {}
        Widgets {}
        Battery {}
    }
}
