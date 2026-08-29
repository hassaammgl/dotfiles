import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "Components"

Scope {
    id: root

    property string page: "main"
    property string statusMsg: ""
    property string pendingSsid: ""
    property bool showPass: false
    property bool busy: false
    property string lastAttemptSsid: ""

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter && adapter.enabled
    readonly property var bat: UPower.displayDevice
    readonly property bool batReady: bat && bat.ready && bat.isLaptopBattery
    readonly property int batPct: {
        if (!batReady)
            return 0;
        const p = bat.percentage;
        return p <= 1 ? Math.round(p * 100) : Math.round(p);
    }
    readonly property bool charging: batReady && bat.state === UPowerDeviceState.Charging

    readonly property var wifiDev: {
        const list = Networking.devices.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].type === DeviceType.Wifi)
                return list[i];
        }
        return null;
    }

    readonly property var wifiNet: {
        if (!wifiDev)
            return null;
        const nets = wifiDev.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i] && nets[i].connected)
                return nets[i];
        }
        return null;
    }

    readonly property var btList: {
        const list = [...Bluetooth.devices.values];
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return b.connected - a.connected;
            return (a.name || "").localeCompare(b.name || "");
        });
        return list;
    }

    function open(): void {
        page = "main";
        statusMsg = "";
        pendingSsid = "";
        if (wifiDev)
            wifiDev.scannerEnabled = true;
        if (adapter && adapter.enabled)
            adapter.discovering = true;
    }

    function shut(): void {
        if (wifiDev)
            wifiDev.scannerEnabled = false;
        if (adapter)
            adapter.discovering = false;
        pendingSsid = "";
        busy = false;
    }

    function rescan(): void {
        statusMsg = "scanning";
        actionProc.exec(["nmcli", "device", "wifi", "rescan"]);
        if (wifiDev) {
            wifiDev.scannerEnabled = false;
            Qt.callLater(() => {
                if (wifiDev && OverlayState.controlCenter)
                    wifiDev.scannerEnabled = true;
            });
        }
    }

    function connectNet(net: var): void {
        if (!net || busy)
            return;
        if (net.connected) {
            busy = true;
            statusMsg = "disconnecting";
            const dev = wifiDev ? wifiDev.name : "";
            if (dev.length)
                actionProc.exec(["nmcli", "device", "disconnect", dev]);
            return;
        }
        if (net.known || net.security === WifiSecurityType.Open) {
            busy = true;
            lastAttemptSsid = net.name;
            statusMsg = `connecting to ${net.name}`;
            actionProc.exec(["nmcli", "device", "wifi", "connect", net.name]);
            return;
        }
        pendingSsid = net.name;
        lastAttemptSsid = net.name;
        passField.text = "";
        Qt.callLater(() => passField.forceActiveFocus());
    }

    function submitPass(): void {
        const ssid = pendingSsid;
        const psk = passField.text;
        if (psk.length < 8) {
            statusMsg = "password too short";
            return;
        }
        busy = true;
        statusMsg = `connecting to ${ssid}`;
        actionProc.exec(["nmcli", "device", "wifi", "connect", ssid, "password", psk]);
    }

    Connections {
        target: OverlayState
        function onControlCenterChanged(): void {
            if (OverlayState.controlCenter)
                root.open();
            else
                root.shut();
        }
    }

    Process {
        id: actionProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.busy = false;
                const out = text.trim();
                if (out.length && /error|fail|secret|password|denied/i.test(out)) {
                    root.statusMsg = "wrong password";
                    return;
                }
                root.statusMsg = "";
                root.pendingSsid = "";
            }
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (!text.trim().length)
                    return;
                root.busy = false;
                root.statusMsg = "connection failed";
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.controlCenter
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            property bool grab: false

            readonly property int pane: Theme.panelWidth(modelData.width)
            readonly property int inset: Theme.barReserve("left") + Theme.space.sm

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                if (visible) {
                    grab = false;
                    Qt.callLater(() => grab = true);
                } else {
                    grab = false;
                }
            }

            HyprlandFocusGrab {
                active: win.visible && win.grab
                windows: [win]
                onCleared: OverlayState.close()
            }

            Shortcut {
                sequence: "Escape"
                enabled: win.visible
                onActivated: OverlayState.close()
            }

            Scrim {
                open: win.visible
                strength: 0.35
                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Card {
                id: pane
                anchors.left: parent.left
                anchors.leftMargin: win.inset
                anchors.verticalCenter: parent.verticalCenter
                width: win.pane
                height: Math.min(520, parent.height - Theme.space.xxl)
                opacity: win.visible ? 1 : 0
                clip: true

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motion.normal
                        easing.type: Theme.motion.enter
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space.md
                    spacing: Theme.space.md

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.page === "wifi" ? "Wi-Fi" : (root.page === "bt" ? "Bluetooth" : "Control")
                            color: Theme.colors.text
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.title
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                        Text {
                            visible: root.page !== "main"
                            text: Theme.icons.chevronLeft
                            color: Theme.colors.textMuted
                            font.family: Theme.font.icon
                            font.pixelSize: Theme.type.icon
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.page = "main";
                                    root.pendingSsid = "";
                                }
                            }
                        }
                    }

                    // Main
                    ColumnLayout {
                        visible: root.page === "main"
                        Layout.fillWidth: true
                        spacing: Theme.space.sm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.space.sm

                            Surface {
                                Layout.fillWidth: true
                                implicitHeight: 64
                                radiusSize: Theme.r.md
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!Networking.wifiEnabled)
                                            Networking.wifiEnabled = true;
                                        root.page = "wifi";
                                        root.rescan();
                                    }
                                }
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: Theme.space.sm
                                    spacing: 2
                                    Text {
                                        text: Theme.icons.wifi
                                        color: Theme.colors.accent
                                        font.family: Theme.font.icon
                                        font.pixelSize: Theme.type.icon
                                    }
                                    Text {
                                        text: "Wi-Fi"
                                        color: Theme.colors.text
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.label
                                    }
                                    Text {
                                        text: root.wifiNet ? root.wifiNet.name : (Networking.wifiEnabled ? "Not connected" : "Off")
                                        color: Theme.colors.textMuted
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.caption
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }
                            }

                            Surface {
                                Layout.fillWidth: true
                                implicitHeight: 64
                                radiusSize: Theme.r.md
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.adapter && !root.adapter.enabled)
                                            root.adapter.enabled = true;
                                        root.page = "bt";
                                    }
                                }
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: Theme.space.sm
                                    spacing: 2
                                    Text {
                                        text: Theme.icons.bluetooth
                                        color: Theme.colors.accent
                                        font.family: Theme.font.icon
                                        font.pixelSize: Theme.type.icon
                                    }
                                    Text {
                                        text: "Bluetooth"
                                        color: Theme.colors.text
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.label
                                    }
                                    Text {
                                        text: root.btOn ? "On" : "Off"
                                        color: Theme.colors.textMuted
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.caption
                                    }
                                }
                            }
                        }

                        SectionHeader {
                            text: "Volume"
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: OsdState.muted ? Theme.icons.volumeMute : Theme.icons.volume
                                color: Theme.colors.text
                                font.family: Theme.font.icon
                                font.pixelSize: Theme.type.icon
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: OsdState.volumeMute(false)
                                }
                            }
                            Slider {
                                Layout.fillWidth: true
                                value: OsdState.vol
                                dimmed: OsdState.muted
                                onApplied: next => OsdState.setVol(next, false)
                            }
                            Text {
                                text: `${Math.round(OsdState.vol * 100)}%`
                                color: Theme.colors.textMuted
                                font.family: Theme.font.mono
                                font.pixelSize: Theme.type.monoSmall
                                Layout.preferredWidth: 36
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: OsdState.micMuted ? Theme.icons.micOff : Theme.icons.mic
                                color: Theme.colors.text
                                font.family: Theme.font.icon
                                font.pixelSize: Theme.type.icon
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: OsdState.micMute(false)
                                }
                            }
                            Slider {
                                Layout.fillWidth: true
                                value: OsdState.micVol
                                dimmed: OsdState.micMuted
                                onApplied: next => OsdState.setMic(next, false)
                            }
                        }

                        SectionHeader {
                            text: "Brightness"
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: Theme.icons.brightness
                                color: Theme.colors.text
                                font.family: Theme.font.icon
                                font.pixelSize: Theme.type.icon
                            }
                            Slider {
                                Layout.fillWidth: true
                                value: OsdState.bri
                                onApplied: next => OsdState.setBri(next, false)
                            }
                            Text {
                                text: `${Math.round(OsdState.bri * 100)}%`
                                color: Theme.colors.textMuted
                                font.family: Theme.font.mono
                                font.pixelSize: Theme.type.monoSmall
                                Layout.preferredWidth: 36
                            }
                        }

                        RowLayout {
                            visible: root.batReady
                            Layout.fillWidth: true
                            Text {
                                text: Theme.icons.battery
                                color: root.batPct <= 15 && !root.charging ? Theme.colors.error : Theme.colors.text
                                font.family: Theme.font.icon
                                font.pixelSize: Theme.type.icon
                            }
                            Text {
                                text: root.charging ? `Battery  ${root.batPct}%  charging` : `Battery  ${root.batPct}%`
                                color: Theme.colors.textSecondary
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.label
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Wi-Fi page
                    ColumnLayout {
                        visible: root.page === "wifi"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.space.sm

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Radio"
                                color: Theme.colors.textSecondary
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.label
                                Layout.fillWidth: true
                            }
                            Toggle {
                                checked: Networking.wifiEnabled
                                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                            }
                        }

                        Text {
                            visible: root.statusMsg.length > 0
                            text: root.statusMsg
                            color: Theme.colors.textMuted
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.caption
                        }

                        ColumnLayout {
                            visible: root.pendingSsid.length > 0
                            Layout.fillWidth: true
                            Text {
                                text: root.pendingSsid
                                color: Theme.colors.text
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.body
                                font.weight: Font.DemiBold
                            }
                            TextField {
                                id: passField
                                Layout.fillWidth: true
                                echoMode: root.showPass ? TextInput.Normal : TextInput.Password
                                placeholderText: "Password"
                                color: Theme.colors.text
                                placeholderTextColor: Theme.colors.textMuted
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.body
                                background: Surface {
                                    radiusSize: Theme.r.sm
                                }
                                onAccepted: root.submitPass()
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Surface {
                                    Layout.fillWidth: true
                                    implicitHeight: 36
                                    radiusSize: Theme.r.sm
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.pendingSsid = ""
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Cancel"
                                        color: Theme.colors.text
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.label
                                    }
                                }
                                Surface {
                                    Layout.fillWidth: true
                                    implicitHeight: 36
                                    radiusSize: Theme.r.sm
                                    color: Theme.colors.accentSoft
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.submitPass()
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Connect"
                                        color: Theme.colors.accent
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.label
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            visible: root.pendingSsid.length === 0 && Networking.wifiEnabled
                            spacing: Theme.space.xs
                            model: root.wifiDev ? root.wifiDev.networks : null
                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view ? ListView.view.width : 0
                                height: 40
                                radius: Theme.r.sm
                                color: modelData && modelData.connected ? Theme.colors.accentSoft : (rowH.containsMouse ? Theme.colors.surfaceElevated : "transparent")
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.space.sm
                                    anchors.rightMargin: Theme.space.sm
                                    Text {
                                        text: Theme.icons.wifi
                                        color: Theme.colors.text
                                        font.family: Theme.font.icon
                                        font.pixelSize: Theme.type.iconSm
                                    }
                                    Text {
                                        text: modelData ? modelData.name : ""
                                        color: Theme.colors.text
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.label
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                                MouseArea {
                                    id: rowH
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.connectNet(modelData)
                                }
                            }
                        }
                    }

                    // Bluetooth page
                    ColumnLayout {
                        visible: root.page === "bt"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.space.sm

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Radio"
                                color: Theme.colors.textSecondary
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.label
                                Layout.fillWidth: true
                            }
                            Toggle {
                                checked: root.btOn
                                onClicked: {
                                    if (root.adapter)
                                        root.adapter.enabled = !root.adapter.enabled;
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            visible: root.btOn
                            spacing: Theme.space.xs
                            model: root.btList
                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 42
                                radius: Theme.r.sm
                                color: modelData.connected ? Theme.colors.accentSoft : (btH.containsMouse ? Theme.colors.surfaceElevated : "transparent")
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.space.sm
                                    Text {
                                        text: modelData.connected ? Theme.icons.bluetoothConn : Theme.icons.bluetooth
                                        color: Theme.colors.text
                                        font.family: Theme.font.icon
                                        font.pixelSize: Theme.type.icon
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        Text {
                                            text: modelData.name || modelData.deviceName || "device"
                                            color: Theme.colors.text
                                            font.family: Theme.font.ui
                                            font.pixelSize: Theme.type.label
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: modelData.connected ? "connected" : (modelData.paired ? "paired" : "available")
                                            color: modelData.connected ? Theme.colors.accent : Theme.colors.textMuted
                                            font.family: Theme.font.ui
                                            font.pixelSize: Theme.type.caption
                                        }
                                    }
                                }
                                MouseArea {
                                    id: btH
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: event => {
                                        if (event.button === Qt.RightButton) {
                                            if (modelData.paired)
                                                modelData.forget();
                                            return;
                                        }
                                        if (modelData.connected)
                                            modelData.disconnect();
                                        else if (modelData.paired)
                                            modelData.connect();
                                        else
                                            modelData.pair();
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: {}
                }
            }
        }
    }
}
