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
