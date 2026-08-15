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
                left: BarState.edge === "left" ? 6 : (BarState.vertical ? 0 : 10)
                right: BarState.edge === "right" ? 6 : (BarState.vertical ? 0 : 10)
                top: BarState.edge === "top" ? 6 : (BarState.vertical ? 10 : 0)
                bottom: BarState.edge === "bottom" ? 6 : (BarState.vertical ? 10 : 0)
            }

            implicitWidth: BarState.vertical ? 48 : 0
            implicitHeight: BarState.vertical ? 0 : 36

            Rectangle {
                anchors.fill: parent
                color: Colors.background
                radius: 14

                GridLayout {
                    anchors.fill: parent
                    anchors.topMargin: BarState.vertical ? 8 : 2
                    anchors.bottomMargin: BarState.vertical ? 8 : 2
                    anchors.leftMargin: BarState.vertical ? 4 : 8
                    anchors.rightMargin: BarState.vertical ? 4 : 8
                    columns: BarState.vertical ? 1 : 20
                    rows: BarState.vertical ? 20 : 1
                    flow: BarState.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
                    rowSpacing: 2
                    columnSpacing: 6

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

                    Bluetooth {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    Network {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    Audio {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    Brightness {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    Cpu {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    Battery {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    Power {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
