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

    property bool ignoreClick: false

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

    function pctOf(net: var): int {
        const s = net.signalStrength;
        return s <= 1 ? Math.round(s * 100) : Math.round(s);
    }

    function isOpen(net: var): bool {
        return net.security === WifiSecurityType.Open;
    }

    function openPop(): void {
        if (wifiDev) {
            if (!Networking.wifiEnabled)
                Networking.wifiEnabled = true;
            wifiDev.scannerEnabled = true;
        }
        pop.visible = true;
    }

    BarButton {
        id: btn
        anchors.centerIn: parent
        icon: {
            if (wiredDev)
                return "󰈀";
            if (!Networking.wifiEnabled)
                return "󰤮";
            if (wifiNet)
                return root.wifiIcon(root.signalPct);
            return "󰤫";
        }
        iconColor: (wiredDev || wifiNet) ? Colors.foreground : Colors.color8
        active: pop.visible
        onClicked: event => {
            if (root.ignoreClick)
                return;
            if (pop.visible)
                pop.visible = false;
            else
                root.openPop();
        }
    }

    PopupWindow {
        id: pop

        visible: false
        color: "transparent"
        implicitWidth: 280
        implicitHeight: 360
        grabFocus: true

        anchor {
            item: root
            edges: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            gravity: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            adjustment: PopupAdjustment.Slide
            margins.left: 10
            margins.right: 10
            margins.top: 10
            margins.bottom: 10
        }

        HyprlandFocusGrab {
            active: pop.visible
            windows: [pop]
            onCleared: {
                pop.visible = false;
                root.ignoreClick = true;
                Qt.callLater(() => {
                    root.ignoreClick = false;
                });
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Colors.background
            border.width: 1
            border.color: Colors.color0
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Wi‑Fi"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: Networking.wifiEnabled ? Colors.accent : Colors.color0

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
                    color: Colors.accent
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    visible: Networking.wifiEnabled
                    model: root.wifiList

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 42
                        radius: 10
                        color: modelData.connected ? Qt.alpha(Colors.accent, 0.22) : (rowHover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: root.wifiIcon(root.pctOf(modelData))
                                color: Colors.foreground
                                font.family: Colors.fontFamily
                                font.pixelSize: 14
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: modelData.name
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.connected ? "connected" : (modelData.known ? "saved" : (root.isOpen(modelData) ? "open" : "secured"))
                                    color: modelData.connected ? Colors.accent : Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                visible: !root.isOpen(modelData)
                                text: ""
                                color: Colors.color8
                                font.family: Colors.fontFamily
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: rowHover
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

                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: "scanning…"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }
                }

                Text {
                    visible: !Networking.wifiEnabled
                    text: "Wi‑Fi is off"
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
