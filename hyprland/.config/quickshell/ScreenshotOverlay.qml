import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.screenshot
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            property int current: 0
            property bool grab: false
            readonly property int usableShift: Math.round(Theme.barReserve("left") / 2)
            readonly property bool picking: ScreenshotState.phase === "pick"
            readonly property var pickActions: [
                {
                    "id": "full",
                    "name": "Full screen",
                    "icon": "󰹑",
                    "tint": Colors.accent
                },
                {
                    "id": "region",
                    "name": "Region",
                    "icon": "󰆞",
                    "tint": Colors.color6
                },
                {
                    "id": "window",
                    "name": "Window",
                    "icon": "󰖲",
                    "tint": Colors.color3
                }
            ]
            readonly property var previewActions: [
                {
                    "id": "copy",
                    "name": "Copy",
                    "icon": "󰆏",
                    "tint": Colors.accent
                },
                {
                    "id": "save",
                    "name": "Save",
                    "icon": "󰆓",
                    "tint": Colors.color6
                },
                {
                    "id": "both",
                    "name": "Copy + save",
                    "icon": "󰠘",
                    "tint": Colors.color3
                }
            ]
            readonly property var actions: picking ? pickActions : previewActions
            readonly property var currentAction: win.actions[Math.min(current, win.actions.length - 1)]

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                if (visible) {
                    current = 0;
                    grab = false;
                    grabDelay.restart();
                } else {
                    grab = false;
                    grabDelay.stop();
                }
            }

            Timer {
                id: grabDelay
                interval: 80
                repeat: false
                onTriggered: win.grab = true
            }

            function run(id: string): void {
                if (id === "full" || id === "region" || id === "window")
                    ScreenshotState.start(id);
                else if (id === "copy")
                    ScreenshotState.copy();
                else if (id === "save")
                    ScreenshotState.save();
                else if (id === "both")
                    ScreenshotState.both();
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
                anchors.horizontalCenterOffset: win.usableShift
                spacing: modelData.height < 900 ? 18 : 28
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

                Rectangle {
                    visible: !win.picking
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(modelData.width < 1600 ? 420 : 640, Math.floor((win.width - Theme.barReserve("left") - 48) * 0.5))
                    height: Math.min(modelData.height < 900 ? 200 : 360, Math.floor(win.height * 0.28))
                    radius: 16
                    color: Theme.colors.background
                    border.width: 1
                    border.color: Qt.alpha(Colors.foreground, 0.16)
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 6
                        source: win.picking ? "" : `file://${ScreenshotState.lastPath}?${ScreenshotState.tick}`
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                    }
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.picking ? "screenshot" : "preview"
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
                            width: 76
                            height: 76

                            Rectangle {
                                anchors.centerIn: parent
                                width: win.current === index ? 72 : 62
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
