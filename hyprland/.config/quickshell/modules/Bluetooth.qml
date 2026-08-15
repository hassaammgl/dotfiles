import Quickshell.Bluetooth
import QtQuick
import ".."

BarButton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter && adapter.enabled
    readonly property int connected: {
        let n = 0;
        for (const d of Bluetooth.devices.values) {
            if (d.connected)
                n++;
        }
        return n;
    }

    visible: adapter !== null
    icon: powered ? (connected > 0 ? "󰂱" : "") : "󰂲"
    iconColor: powered ? Colors.foreground : Colors.color8

    onClicked: event => {
        if (root.adapter)
            root.adapter.enabled = !root.adapter.enabled;
    }
}
