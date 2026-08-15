import Quickshell.Networking
import QtQuick
import ".."

BarButton {
    id: root

    readonly property var wifiDev: {
        const list = Networking.devices.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].type === DeviceType.Wifi)
                return list[i];
        }
        return null;
    }

    readonly property var wiredDev: {
        const list = Networking.devices.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].type === DeviceType.Wired && list[i].connected)
                return list[i];
        }
        return null;
    }

    readonly property var wifiNet: {
        if (!wifiDev)
            return null;
        const nets = wifiDev.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i].connected)
                return nets[i];
        }
        return null;
    }

    readonly property int signal: wifiNet ? wifiNet.signalStrength : 0

    icon: {
        if (wiredDev)
            return "󰀂";
        if (wifiNet) {
            if (signal >= 80)
                return "󰤨";
            if (signal >= 60)
                return "󰤥";
            if (signal >= 40)
                return "󰤢";
            if (signal >= 20)
                return "󰤟";
            return "󰤯";
        }
        return "󰤮";
    }
    iconColor: (wiredDev || wifiNet) ? Colors.foreground : Colors.color8

    onClicked: event => {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
}
