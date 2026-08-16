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
            visible: OverlayState.power
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            property int current: 4
            readonly property var actions: [
                {
                    "id": "lock",
                    "name": "Lock",
                    "icon": "",
                    "tint": Colors.foreground
                },
                {
                    "id": "logout",
                    "name": "Logout",
                    "icon": "",
                    "tint": Colors.accent
                },
                {
                    "id": "sleep",
                    "name": "Sleep",
                    "icon": "",
                    "tint": Colors.color6
                },
                {
                    "id": "reboot",
                    "name": "Reboot",
                    "icon": "",
                    "tint": Colors.color3
                },
                {
                    "id": "power",
                    "name": "Power",
                    "icon": "",
                    "tint": Colors.color1
                }
            ]
            readonly property var currentAction: win.actions[win.current]

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                if (visible)
                    current = 4;
            }

            function run(id: string): void {
                OverlayState.close();
                if (id === "lock")
                    LockState.lock();
                else if (id === "logout")
                    Hyprland.dispatch("exit");
                else if (id === "sleep")
                    Quickshell.execDetached(["systemctl", "suspend"]);
                else if (id === "reboot")
                    Quickshell.execDetached(["systemctl", "reboot"]);
                else if (id === "power")
                    Quickshell.execDetached(["systemctl", "poweroff"]);
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
                sequence: "Left"
                enabled: win.visible
                onActivated: win.current = Math.max(0, win.current - 1)
            }

            Shortcut {
                sequence: "Right"
                enabled: win.visible
                onActivated: win.current = Math.min(win.actions.length - 1, win.current + 1)
            }

            Shortcut {
                sequence: "Return"
                enabled: win.visible
                onActivated: win.run(win.currentAction.id)
            }

            Shortcut {
                sequence: "Enter"
                enabled: win.visible
                onActivated: win.run(win.currentAction.id)
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.background, 0.55)

                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 28
                opacity: win.visible ? 1 : 0
                scale: win.visible ? 1 : 0.94

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

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "session"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.currentAction.name
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 28
                        font.weight: Font.DemiBold
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 18

                    Repeater {
                        model: win.actions

                        Item {
                            required property var modelData
                            required property int index
                            width: 88
                            height: 88

                            Rectangle {
                                anchors.centerIn: parent
                                width: win.current === index ? 84 : 72
                                height: width
                                radius: width / 2
                                color: Qt.alpha(modelData.tint, win.current === index ? 0.42 : 0.16)
                                border.width: win.current === index ? 2 : 0
                                border.color: modelData.tint

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 120
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    color: modelData.tint
                                    font.family: Colors.fontFamily
                                    font.pixelSize: win.current === index ? 26 : 20
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: win.current = index
                                onClicked: win.run(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
