import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.dashboard
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            HyprlandFocusGrab {
                active: win.visible
                windows: [win]
                onCleared: OverlayState.close()
            }

            Shortcut {
                sequence: "Escape"
                enabled: win.visible
                onActivated: OverlayState.close()
            }

            Shortcut {
                sequence: "Return"
                enabled: win.visible
                onActivated: {
                    OverlayState.close();
                    Quickshell.execDetached(["kitty", "btop"]);
                }
            }

            function meterColor(pct: real): color {
                if (pct > 85)
                    return Colors.secondary;
                if (pct > 55)
                    return Colors.color3;
                return Colors.accent;
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.background, 0.5)

                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: Math.min(680, parent.width - 48)
                height: Math.min(480, parent.height - 48)
                radius: Theme.r.lg
                color: Theme.withAlpha(Theme.colors.background, 0.96)
                border.width: 1
                border.color: Theme.colors.border
                opacity: win.visible ? 1 : 0
                scale: win.visible ? 1 : 0.97

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "󰍛  dashboard"
                            color: Colors.accent
                            font.family: Colors.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: DashState.hostLabel
                            color: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 11
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: `load ${DashState.loadLabel}   up ${DashState.uptimeLabel}`
                            color: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 11
                        }

                        Rectangle {
                            width: openLabel.implicitWidth + 14
                            height: 24
                            radius: 8
                            color: Qt.alpha(Colors.accent, btopHover.containsMouse ? 0.4 : 0.16)
                            border.width: 1
                            border.color: Qt.alpha(Colors.accent, 0.5)

                            Text {
                                id: openLabel
                                anchors.centerIn: parent
                                text: "btop ↵"
                                color: Colors.foreground
                                font.family: Colors.fontFamily
                                font.pixelSize: 10
                            }

                            MouseArea {
                                id: btopHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    OverlayState.close();
                                    Quickshell.execDetached(["kitty", "btop"]);
                                }
                            }
                        }
                    }

                    // CPU
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 88
                        radius: 12
                        color: Qt.alpha(Colors.color0, 0.28)
                        border.width: 1
                        border.color: Colors.color0

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "CPU"
                                    color: Colors.accent
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: `${DashState.cpuPct}%`
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 18
                                    font.weight: Font.DemiBold
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: `${DashState.corePcts.length} cores`
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 11
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 10
                                radius: 5
                                color: Qt.alpha(Colors.background, 0.7)

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * DashState.cpuPct / 100
                                    radius: 5
                                    color: win.meterColor(DashState.cpuPct)
                                }
                            }

                            Row {
                                Layout.fillWidth: true
                                spacing: 3

                                Repeater {
                                    model: DashState.corePcts

                                    Rectangle {
                                        required property var modelData
                                        width: Math.max(12, (panel.width - 56) / Math.max(1, DashState.corePcts.length) - 3)
                                        height: 8
                                        radius: 3
                                        color: Qt.alpha(Colors.background, 0.7)

                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            width: parent.width * modelData / 100
                                            radius: 3
                                            color: win.meterColor(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // MEM / DISK / NET
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        spacing: 8

                        Repeater {
                            model: [
                                {
                                    "title": "MEM",
                                    "pct": DashState.memPct,
                                    "label": DashState.memLabel,
                                    "sub": `swap ${DashState.swapPct}%`,
                                    "tint": Colors.color6
                                },
                                {
                                    "title": "DISK",
                                    "pct": DashState.diskPct,
                                    "label": DashState.diskLabel,
                                    "sub": "root /",
                                    "tint": Colors.color3
                                },
                                {
                                    "title": "NET",
                                    "pct": -1,
                                    "label": `↓ ${DashState.fmtSpeed(DashState.downBps)}`,
                                    "sub": `↑ ${DashState.fmtSpeed(DashState.upBps)}`,
                                    "tint": Colors.color4
                                }
                            ]

                            Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 12
                                color: Qt.alpha(Colors.color0, 0.28)
                                border.width: 1
                                border.color: Colors.color0

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 6

                                    Text {
                                        text: modelData.title
                                        color: modelData.tint
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: modelData.pct >= 0 ? `${modelData.pct}%` : modelData.label
                                        color: Colors.foreground
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 18
                                        font.weight: Font.DemiBold
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 8
                                        radius: 4
                                        visible: modelData.pct >= 0
                                        color: Qt.alpha(Colors.background, 0.7)

                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            width: parent.width * Math.max(0, Math.min(1, modelData.pct / 100))
                                            radius: 4
                                            color: modelData.tint
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.pct >= 0 ? modelData.label : modelData.sub
                                        color: Colors.color8
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: modelData.pct >= 0
                                        text: modelData.sub
                                        color: Colors.color8
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }

                    // Processes
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: Qt.alpha(Colors.color0, 0.28)
                        border.width: 1
                        border.color: Colors.color0
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "PROCESSES"
                                    color: Colors.accent
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "sorted by cpu"
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text {
                                    text: "PID"
                                    Layout.preferredWidth: 56
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "USER"
                                    Layout.preferredWidth: 72
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "CPU%"
                                    Layout.preferredWidth: 48
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "MEM%"
                                    Layout.preferredWidth: 48
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "Command"
                                    Layout.fillWidth: true
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }
                            }

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                spacing: 2
                                model: DashState.procs

                                delegate: Rectangle {
                                    required property var modelData
                                    width: ListView.view.width
                                    height: 22
                                    radius: 4
                                    color: rowHover.containsMouse ? Qt.alpha(Colors.accent, 0.12) : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 8

                                        Text {
                                            text: modelData.pid
                                            Layout.preferredWidth: 56
                                            color: Colors.color8
                                            font.family: Colors.fontFamily
                                            font.pixelSize: 11
                                        }
                                        Text {
                                            text: modelData.user
                                            Layout.preferredWidth: 72
                                            color: Colors.foreground
                                            font.family: Colors.fontFamily
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: modelData.cpu.toFixed(1)
                                            Layout.preferredWidth: 48
                                            color: modelData.cpu > 50 ? Colors.secondary : Colors.accent
                                            font.family: Colors.fontFamily
                                            font.pixelSize: 11
                                        }
                                        Text {
                                            text: modelData.mem.toFixed(1)
                                            Layout.preferredWidth: 48
                                            color: Colors.color6
                                            font.family: Colors.fontFamily
                                            font.pixelSize: 11
                                        }
                                        Text {
                                            text: modelData.cmd
                                            Layout.fillWidth: true
                                            color: Colors.foreground
                                            font.family: Colors.fontFamily
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: rowHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "ALT + D  ·  Esc close  ·  Enter open btop"
                        color: Qt.alpha(Colors.color8, 0.7)
                        font.family: Colors.fontFamily
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
