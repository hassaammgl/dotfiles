import Quickshell
import Quickshell.Services.UPower
import QtQuick
import ".."

BarButton {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property bool ready: bat && bat.ready && bat.isLaptopBattery
    readonly property int percent: {
        if (!ready)
            return 0;
        const p = bat.percentage;
        return p <= 1 ? Math.round(p * 100) : Math.round(p);
    }
    readonly property bool charging: ready && bat.state === UPowerDeviceState.Charging

    visible: ready
    icon: {
        if (!ready)
            return "";
        if (charging) {
            if (percent >= 95)
                return "󰂅";
            if (percent >= 80)
                return "󰂋";
            if (percent >= 60)
                return "󰂊";
            if (percent >= 40)
                return "󰢝";
            if (percent >= 20)
                return "󰂇";
            return "󰢜";
        }
        if (percent >= 95)
            return "󰁹";
        if (percent >= 80)
            return "󰂂";
        if (percent >= 60)
            return "󰁿";
        if (percent >= 40)
            return "󰁽";
        if (percent >= 20)
            return "󰁻";
        return "󰁺";
    }
    label: `${percent}%`
    labelOnHover: false
    iconColor: percent <= 15 && !charging ? Colors.color1 : Colors.foreground
}
