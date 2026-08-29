import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "modules"

Scope {
    id: root

    readonly property real cpuPct: Host.cpuPct
    readonly property real memPct: Host.memPct
    readonly property real diskPct: Host.diskPct
    readonly property string diskLabel: Host.diskLabel
    readonly property string uptimeLabel: Host.uptimeLabel

    readonly property var bat: UPower.displayDevice
    readonly property bool batReady: bat && bat.ready && bat.isLaptopBattery
    readonly property int batPct: {
        if (!batReady)
            return 0;
        const p = bat.percentage;
        return p <= 1 ? Math.round(p * 100) : Math.round(p);
    }
    readonly property bool batCharging: batReady && bat.state === UPowerDeviceState.Charging

    function greetingFor(d: date): string {
        const h = d.getHours();
        if (h < 5)
            return "late night vibes";
        if (h < 12)
            return "good morning";
        if (h < 17)
            return "good afternoon";
        if (h < 21)
            return "good evening";
        return "good night";
    }

    function meterColor(pct: real): color {
        if (pct >= 90)
            return Colors.color1;
        if (pct >= 70)
            return Colors.color12;
        return Colors.accent;
    }

    SystemClock {
        id: liveClock
        precision: SystemClock.Seconds
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: WidgetState.enabled
            color: "transparent"
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            aboveWindows: false
            WlrLayershell.namespace: "quickshell-widgets"
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            readonly property bool topSide: WidgetState.corner.indexOf("top") === 0
            readonly property bool leftSide: WidgetState.corner.indexOf("left") >= 0
            readonly property real s: Math.max(0.75, Math.min(1.35, WidgetState.scale))
            readonly property int cardW: Math.round(236 * s)

            anchors {
                left: leftSide
                right: !leftSide
                top: topSide
                bottom: !topSide
            }

            margins {
                left: leftSide ? 20 : 0
                right: leftSide ? 0 : 20
                top: topSide ? 20 : 0
                bottom: topSide ? 0 : 20
            }

            implicitWidth: Math.max(shell.implicitWidth, 1)
            implicitHeight: Math.max(shell.implicitHeight, 1)

            component SoftCard: Rectangle {
                id: card
                default property alias content: body.data
                property bool catchClicks: true
                signal hideRequested
                signal activated

                width: win.cardW
                radius: 16
                color: Qt.alpha(Colors.background, 0.86)
                border.width: 1
                border.color: Colors.color0
                implicitHeight: body.implicitHeight + 22

                Column {
                    id: body
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    enabled: card.catchClicks
                    z: 5
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.RightButton)
                            card.hideRequested();
                        else
                            card.activated();
                    }
                }
            }

            component MeterRow: Item {
                property string label: ""
                property string value: ""
                property real pct: 0
                property color fill: Colors.accent
                width: win.cardW - 24
                height: 28

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: parent.label
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: Math.round(10 * win.s)
                }

                Text {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    text: parent.value
                    color: Colors.foreground
                    font.family: Colors.fontFamily
                    font.pixelSize: Math.round(10 * win.s)
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 6
                    radius: 3
                    color: Qt.alpha(Colors.color0, 0.7)

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, parent.parent.pct / 100))
                        height: parent.height
                        radius: parent.radius
                        color: parent.parent.fill
                        Behavior on width {
                            NumberAnimation {
                                duration: 280
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            Item {
                id: shell
                implicitWidth: row.implicitWidth
                implicitHeight: row.implicitHeight

                RowLayout {
                    id: row
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: Math.round(12 * win.s)
                    layoutDirection: win.leftSide ? Qt.LeftToRight : Qt.RightToLeft

                    Column {
                        Layout.alignment: win.topSide ? Qt.AlignTop : Qt.AlignBottom
                        spacing: Math.round(10 * win.s)

                        SoftCard {
                            visible: WidgetState.showClock
                            onHideRequested: WidgetState.showClock = false

                            Text {
                                visible: WidgetState.showGreeting
                                text: root.greetingFor(liveClock.date)
                                color: Colors.accent
                                font.family: Colors.fontFamily
                                font.pixelSize: Math.round(11 * win.s)
                            }

                            Text {
                                text: Qt.formatDateTime(liveClock.date, "h:mm AP")
                                color: Colors.foreground
                                font.family: Colors.fontFamily
                                font.pixelSize: Math.round(42 * win.s)
                                font.weight: Font.Bold
                            }

                            Text {
                                text: Qt.formatDateTime(liveClock.date, "dddd · d MMM yyyy")
                                color: Colors.color8
                                font.family: Colors.fontFamily
                                font.pixelSize: Math.round(12 * win.s)
                            }

                            Text {
                                visible: root.uptimeLabel.length > 1
                                text: `󰔟  ${root.uptimeLabel.replace(/^UP /, "")} up`
                                color: Colors.color6
                                font.family: Colors.fontFamily
                                font.pixelSize: Math.round(10 * win.s)
                                topPadding: 2
                            }
                        }

                        SoftCard {
                            visible: WidgetState.showCalendar
                            onHideRequested: WidgetState.showCalendar = false

                            Item {
                                width: win.cardW - 24
                                height: Math.round(16 * win.s)

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: Qt.formatDateTime(liveClock.date, "MMMM yyyy")
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: Math.round(12 * win.s)
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "󰸗"
                                    color: Colors.accent
                                    font.family: Colors.fontFamily
                                    font.pixelSize: Math.round(14 * win.s)
                                }
                            }

                            Row {
                                id: weekRow
                                spacing: 4
                                width: win.cardW - 24

                                Repeater {
                                    model: 7

                                    Rectangle {
                                        id: dayCell
                                        required property int index
                                        readonly property date day: {
                                            const d = new Date(liveClock.date.getTime());
                                            const dow = (d.getDay() + 6) % 7;
                                            d.setDate(d.getDate() - dow + index);
                                            return d;
                                        }
                                        readonly property bool isToday: Qt.formatDate(day, "yyyy-MM-dd") === Qt.formatDate(liveClock.date, "yyyy-MM-dd")
                                        width: Math.floor((weekRow.width - 24) / 7)
                                        height: width + 18
                                        radius: 10
                                        color: isToday ? Qt.alpha(Colors.accent, 0.28) : Qt.alpha(Colors.color0, 0.35)
                                        border.width: isToday ? 1 : 0
                                        border.color: Colors.accent

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Qt.formatDate(dayCell.day, "dd")
                                                color: dayCell.isToday ? Colors.accent : Colors.foreground
                                                font.family: Colors.fontFamily
                                                font.pixelSize: Math.round(12 * win.s)
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Qt.formatDate(dayCell.day, "ddd").slice(0, 2)
                                                color: Colors.color8
                                                font.family: Colors.fontFamily
                                                font.pixelSize: Math.round(9 * win.s)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        SoftCard {
                            visible: WidgetState.showStats
                            onHideRequested: WidgetState.showStats = false
                            onActivated: OverlayState.toggleDashboard()

                            Row {
                                spacing: 6

                                Text {
                                    text: "󰒍"
                                    color: Colors.accent
                                    font.family: Colors.fontFamily
                                    font.pixelSize: Math.round(13 * win.s)
                                }

                                Text {
                                    text: "system"
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: Math.round(12 * win.s)
                                    font.weight: Font.DemiBold
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    visible: root.batReady
                                    text: `  ${root.batCharging ? "󰂄" : "󰁹"} ${root.batPct}%`
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: Math.round(11 * win.s)
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MeterRow {
                                label: "cpu"
                                value: `${root.cpuPct}%`
                                pct: root.cpuPct
                                fill: root.meterColor(root.cpuPct)
                            }

                            MeterRow {
                                label: "mem"
                                value: `${root.memPct}%`
                                pct: root.memPct
                                fill: root.meterColor(root.memPct)
                            }

                            MeterRow {
                                label: "disk"
                                value: `${root.diskPct}%  ${root.diskLabel}`
                                pct: root.diskPct
                                fill: root.meterColor(root.diskPct)
                            }
                        }

                        SoftCard {
                            visible: WidgetState.showMedia && MediaState.ready
                            catchClicks: false

                            Row {
                                spacing: 10
                                width: win.cardW - 24

                                Rectangle {
                                    width: Math.round(52 * win.s)
                                    height: width
                                    radius: 12
                                    color: Qt.alpha(Colors.color0, 0.55)
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: MediaState.art
                                        fillMode: Image.PreserveAspectCrop
                                        visible: MediaState.art.length > 0
                                        asynchronous: true
                                    }

                                    Mascot {
                                        anchors.centerIn: parent
                                        visible: MediaState.art.length === 0
                                        fileName: "media.gif"
                                        maxH: Math.round(44 * win.s)
                                        playing: MediaState.playing && WidgetState.enabled
                                    }
                                }

                                Column {
                                    spacing: 4
                                    width: parent.width - Math.round(62 * win.s)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        width: parent.width
                                        text: MediaState.title
                                        elide: Text.ElideRight
                                        color: Colors.foreground
                                        font.family: Colors.fontFamily
                                        font.pixelSize: Math.round(12 * win.s)
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        width: parent.width
                                        visible: MediaState.artist.length > 0
                                        text: MediaState.artist
                                        elide: Text.ElideRight
                                        color: Colors.color8
                                        font.family: Colors.fontFamily
                                        font.pixelSize: Math.round(10 * win.s)
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 4
                                        radius: 2
                                        color: Qt.alpha(Colors.color0, 0.7)
                                        visible: MediaState.length > 0

                                        Rectangle {
                                            width: parent.width * MediaState.progress
                                            height: parent.height
                                            radius: parent.radius
                                            color: Colors.accent
                                        }
                                    }

                                    Row {
                                        spacing: 12

                                        Text {
                                            text: "󰒮"
                                            color: Colors.color8
                                            font.family: Colors.fontFamily
                                            font.pixelSize: Math.round(14 * win.s)
                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -6
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: MediaState.prev()
                                            }
                                        }

                                        Text {
                                            text: MediaState.playing ? "󰏤" : "󰐊"
                                            color: Colors.accent
                                            font.family: Colors.fontFamily
                                            font.pixelSize: Math.round(16 * win.s)
                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -6
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: MediaState.toggle()
                                            }
                                        }

                                        Text {
                                            text: "󰒭"
                                            color: Colors.color8
                                            font.family: Colors.fontFamily
                                            font.pixelSize: Math.round(14 * win.s)
                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -6
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: MediaState.next()
                                            }
                                        }

                                        Text {
                                            text: "󰅖"
                                            color: Colors.color8
                                            font.family: Colors.fontFamily
                                            font.pixelSize: Math.round(12 * win.s)
                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -6
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: WidgetState.showMedia = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        visible: WidgetState.showMascot
                        Layout.alignment: win.topSide ? Qt.AlignTop : Qt.AlignBottom
                        spacing: 8

                        Rectangle {
                            visible: WidgetState.showGreeting
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: bubbleTxt.implicitWidth + 18
                            height: bubbleTxt.implicitHeight + 14
                            radius: 12
                            color: Qt.alpha(Colors.background, 0.88)
                            border.width: 1
                            border.color: Colors.color0

                            Text {
                                id: bubbleTxt
                                anchors.centerIn: parent
                                text: {
                                    if (MediaState.ready && MediaState.playing)
                                        return "♪ listening…";
                                    if (root.cpuPct >= 85)
                                        return "cpu going brrr";
                                    return root.greetingFor(liveClock.date);
                                }
                                color: Colors.foreground
                                font.family: Colors.fontFamily
                                font.pixelSize: Math.round(11 * win.s)
                            }
                        }

                        Item {
                            width: Math.max(mascot.implicitWidth, Math.round(130 * win.s))
                            height: Math.max(mascot.implicitHeight, Math.round(100 * win.s))
                            anchors.horizontalCenter: parent.horizontalCenter

                            Mascot {
                                id: mascot
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                fileName: WidgetState.character
                                maxH: Math.round(170 * win.s)
                                playing: WidgetState.enabled && win.visible
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: event => {
                                    if (event.button === Qt.RightButton) {
                                        WidgetState.showMascot = false;
                                        return;
                                    }
                                    if (event.button === Qt.MiddleButton) {
                                        WidgetState.cycleCorner();
                                        return;
                                    }
                                    WidgetState.cycleCharacter();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "widgets"

        function toggle(): void {
            WidgetState.toggle();
        }

        function show(): void {
            WidgetState.enabled = true;
        }

        function hide(): void {
            WidgetState.enabled = false;
        }

        function cycle(): void {
            WidgetState.cycleCharacter();
        }

        function corner(): void {
            WidgetState.cycleCorner();
        }

        function clock(): void {
            WidgetState.showClock = !WidgetState.showClock;
        }

        function calendar(): void {
            WidgetState.showCalendar = !WidgetState.showCalendar;
        }

        function stats(): void {
            WidgetState.showStats = !WidgetState.showStats;
        }

        function media(): void {
            WidgetState.showMedia = !WidgetState.showMedia;
        }

        function mascot(): void {
            WidgetState.showMascot = !WidgetState.showMascot;
        }

        function greeting(): void {
            WidgetState.showGreeting = !WidgetState.showGreeting;
        }

        function reset(): void {
            WidgetState.resetAll();
        }
    }
}
