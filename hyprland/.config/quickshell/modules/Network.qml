import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    readonly property var devices: Networking.devices.values

    readonly property var wifiDev: {
        const list = root.devices;
        for (let i = 0; i < list.length; i++) {
            if (list[i].type === DeviceType.Wifi)
                return list[i];
        }
        return null;
    }

    readonly property var wiredDev: {
        const list = root.devices;
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

    readonly property int signalPct: {
        if (!wifiNet)
            return 0;
        const s = wifiNet.signalStrength;
        return s <= 1 ? Math.round(s * 100) : Math.round(s);
    }

    readonly property var wifiList: {
        if (!wifiDev)
            return [];
        return [...wifiDev.networks.values].sort((a, b) => {
            if (a.connected !== b.connected)
                return b.connected - a.connected;
            return b.signalStrength - a.signalStrength;
        });
    }

    function wifiIcon(pct: int): string {
        if (pct >= 80)
            return "󰤨";
        if (pct >= 60)
            return "󰤥";
        if (pct >= 40)
            return "󰤢";
        if (pct >= 20)
            return "󰤟";
        return "󰤯";
    }

    BarButton {
        id: btn
        anchors.centerIn: parent
        icon: {
            if (wiredDev)
                return "󰀂";
            if (!Networking.wifiEnabled)
                return "󰤮";
            if (wifiNet)
                return root.wifiIcon(root.signalPct);
            return "󰤫";
        }
        iconColor: (wiredDev || wifiNet) ? Colors.foreground : Colors.color8
        onClicked: event => {
            pop.visible = !pop.visible;
            if (pop.visible) {
                if (!Networking.wifiEnabled)
                    Networking.wifiEnabled = true;
                if (root.wifiDev)
                    root.wifiDev.scannerEnabled = true;
            }
        }
    }

    PopupWindow {
        id: pop

        visible: false
        color: "transparent"
        implicitWidth: 260
        implicitHeight: Math.min(360, sheet.implicitHeight + 20)

        anchor {
            item: root
            edges: BarState.edge === "right" ? Edges.Left : Edges.Right
            gravity: BarState.edge === "right" ? Edges.Left : Edges.Right
            margins.left: 10
            margins.right: 10
        }

        HyprlandFocusGrab {
            active: pop.visible
            windows: [pop]
            onCleared: pop.visible = false
        }

        Rectangle {
            id: sheet
            anchors.fill: parent
            color: Colors.background
            radius: 18
            border.width: 1
            border.color: Colors.color0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Wi‑Fi"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: Networking.wifiEnabled ? Colors.color4 : Colors.color0

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: Networking.wifiEnabled ? parent.width - width - 3 : 3
                            color: Colors.foreground

                            Behavior on x {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }
                }

                Text {
                    visible: !!root.wifiNet
                    text: root.wifiNet ? root.wifiNet.name : ""
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentHeight: listCol.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    visible: Networking.wifiEnabled

                    Column {
                        id: listCol
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: root.wifiList

                            Rectangle {
                                required property var modelData
                                width: listCol.width
                                height: 36
                                radius: 10
                                color: modelData.connected ? Qt.rgba(1, 1, 1, 0.10) : (cellHover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        text: {
                                            const s = modelData.signalStrength;
                                            const pct = s <= 1 ? Math.round(s * 100) : Math.round(s);
                                            return root.wifiIcon(pct);
                                        }
                                        color: Colors.foreground
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: modelData.name
                                        color: Colors.foreground
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        visible: modelData.connected
                                        text: "connected"
                                        color: Colors.color4
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 10
                                    }
                                }

                                MouseArea {
                                    id: cellHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.connected)
                                            modelData.disconnect();
                                        else
                                            modelData.connect();
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: Networking.wifiEnabled && root.wifiList.length === 0
                    text: "Scanning…"
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
