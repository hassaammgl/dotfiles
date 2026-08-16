import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
    IpcHandler {
        target: "osd"

        function volumeUp(): void {
            OsdState.volumeUp();
        }

        function volumeDown(): void {
            OsdState.volumeDown();
        }

        function volumeMute(): void {
            OsdState.volumeMute(true);
        }

        function micMute(): void {
            OsdState.micMute(true);
        }

        function brightnessUp(): void {
            OsdState.brightnessUp();
        }

        function brightnessDown(): void {
            OsdState.brightnessDown();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OsdState.visible
            color: "transparent"
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            aboveWindows: true
            WlrLayershell.namespace: "quickshell-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            implicitWidth: 280
            implicitHeight: 64

            anchors {
                bottom: true
                left: true
            }

            margins {
                bottom: 72
                left: Math.max(0, Math.round((modelData.width - 280) / 2))
            }

            Rectangle {
                anchors.fill: parent
                radius: 20
                color: Qt.alpha(Colors.background, 0.92)
                border.width: 1
                border.color: Colors.color0
                opacity: OsdState.visible ? 1 : 0
                scale: OsdState.visible ? 1 : 0.94

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 14

                    Text {
                        text: OsdState.icon
                        color: OsdState.dimmed ? Colors.color8 : Colors.accent
                        font.family: Colors.fontFamily
                        font.pixelSize: 22
                        Layout.preferredWidth: 28
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: Colors.color0

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: Math.max(OsdState.dimmed ? 0 : 8, parent.width * Math.max(0, Math.min(1, OsdState.value)))
                            radius: 4
                            color: OsdState.dimmed ? Colors.color8 : Colors.accent

                            Behavior on width {
                                NumberAnimation {
                                    duration: 90
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    Text {
                        text: OsdState.dimmed ? "mute" : OsdState.percent
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        Layout.preferredWidth: 48
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
