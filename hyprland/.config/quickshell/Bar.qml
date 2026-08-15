import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "modules"

Scope {
    id: root

    IpcHandler {
        target: "bar"

        function toggle(): void {
            BarState.visible = !BarState.visible;
        }

        function show(): void {
            BarState.visible = true;
        }

        function hide(): void {
            BarState.visible = false;
        }

        function cycleEdge(): void {
            BarState.cycle();
        }

        function setEdge(edge: string): void {
            BarState.edge = edge;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData
            screen: modelData
            visible: BarState.visible
            color: "transparent"

            anchors {
                left: BarState.edge === "left" || !BarState.vertical
                right: BarState.edge === "right" || !BarState.vertical
                top: BarState.edge === "top" || BarState.vertical
                bottom: BarState.edge === "bottom" || BarState.vertical
            }

            margins {
                left: BarState.edge === "left" ? 4 : (BarState.vertical ? 0 : 8)
                right: BarState.edge === "right" ? 4 : (BarState.vertical ? 0 : 8)
                top: BarState.edge === "top" ? 4 : (BarState.vertical ? 8 : 0)
                bottom: BarState.edge === "bottom" ? 4 : (BarState.vertical ? 8 : 0)
            }

            implicitWidth: BarState.vertical ? 38 : 0
            implicitHeight: BarState.vertical ? 0 : 34

            GridLayout {
                anchors.fill: parent
                columns: BarState.vertical ? 1 : 9
                rows: BarState.vertical ? 9 : 1
                flow: BarState.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
                rowSpacing: 5
                columnSpacing: 5

                Launcher {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Workspaces {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Item {
                    Layout.fillHeight: BarState.vertical
                    Layout.fillWidth: !BarState.vertical
                }

                Clock {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Item {
                    Layout.fillHeight: BarState.vertical
                    Layout.fillWidth: !BarState.vertical
                }

                Tray {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                StatusIcons {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Power {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
            }
        }
    }
}
