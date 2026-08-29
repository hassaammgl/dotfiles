import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "Components"

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

            implicitWidth: Theme.osd.width
            implicitHeight: Theme.osd.height

            anchors {
                bottom: true
                left: true
            }

            margins {
                bottom: Theme.space.xxl
                left: Theme.osdX(modelData.width)
            }

            Card {
                anchors.fill: parent
                radiusSize: Theme.r.lg
                opacity: OsdState.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motion.fast
                        easing.type: Theme.motion.enter
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space.md
                    anchors.rightMargin: Theme.space.md
                    spacing: Theme.space.md

                    Text {
                        text: OsdState.icon
                        color: OsdState.dimmed ? Theme.colors.textMuted : Theme.colors.accent
                        font.family: Theme.font.icon
                        font.pixelSize: Theme.type.iconLg
                        Layout.preferredWidth: 24
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Slider {
                        Layout.fillWidth: true
                        value: OsdState.value
                        dimmed: OsdState.dimmed
                        onApplied: next => {
                            if (OsdState.kind === "brightness")
                                OsdState.setBri(next, false);
                            else if (OsdState.kind === "mic")
                                OsdState.setMic(next, false);
                            else
                                OsdState.setVol(next, false);
                        }
                    }

                    Text {
                        text: OsdState.dimmed ? "mute" : OsdState.percent
                        color: Theme.colors.text
                        font.family: Theme.font.mono
                        font.pixelSize: Theme.type.monoSmall
                        font.weight: Font.DemiBold
                        Layout.preferredWidth: 40
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
