import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "modules"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.notifs
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
                width: Math.min(480, parent.width - 64)
                spacing: 18
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
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "notifications"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: NotifState.items.length ? `${NotifState.items.length} in history` : "empty"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                    }
                }

                ListView {
                    id: list
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.min(400, win.height * 0.5)
                    clip: true
                    spacing: 8
                    boundsBehavior: Flickable.StopAtBounds
                    model: NotifState.items

                    Column {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        spacing: 12

                        Mascot {
                            anchors.horizontalCenter: parent.horizontalCenter
                            fileName: "empty.png"
                            maxH: 100
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "nothing here"
                            color: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 14
                        }
                    }

                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        required property int index
                        readonly property var entry: modelData
                        readonly property color accent: NotifState.accentFor(entry)

                        width: list.width
                        implicitHeight: inner.implicitHeight + 24
                        radius: 18
                        color: Qt.alpha(Colors.background, 0.92)
                        border.width: 1
                        border.color: Colors.color0

                        Column {
                            id: inner
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 8

                            RowLayout {
                                width: parent.width
                                spacing: 12

                                Rectangle {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    radius: 11
                                    color: Qt.alpha(card.accent, 0.18)

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        visible: entry.image && entry.image.length > 0
                                        source: entry.image || ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                    }

                                    IconImage {
                                        anchors.centerIn: parent
                                        visible: !(entry.image && entry.image.length > 0) && entry.appIcon && entry.appIcon.length > 0
                                        implicitSize: 18
                                        source: entry.appIcon ? Quickshell.iconPath(entry.appIcon) : ""
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !(entry.image && entry.image.length > 0) && !(entry.appIcon && entry.appIcon.length > 0)
                                        text: (entry.appName || "?").charAt(0).toUpperCase()
                                        color: card.accent
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: entry.appName || "system"
                                        color: Colors.color8
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        visible: entry.summary && entry.summary.length > 0
                                        text: entry.summary
                                        color: Colors.foreground
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: NotifState.timeAgo(entry.time)
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 11
                                    Layout.alignment: Qt.AlignTop
                                }

                                Text {
                                    text: "✕"
                                    color: dropHover.containsMouse ? Colors.foreground : Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 13
                                    Layout.alignment: Qt.AlignTop

                                    MouseArea {
                                        id: dropHover
                                        anchors.fill: parent
                                        anchors.margins: -8
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: NotifState.removeAt(card.index)
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                visible: entry.body && entry.body.length > 0
                                text: entry.body
                                color: Colors.color8
                                font.family: Colors.fontFamily
                                font.pixelSize: 12
                                textFormat: Text.StyledText
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Rectangle {
                    visible: NotifState.items.length > 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 96
                    height: 34
                    radius: 17
                    color: clearHover.containsMouse ? Qt.alpha(Colors.accent, 0.35) : Qt.alpha(Colors.accent, 0.16)
                    border.width: 1
                    border.color: Qt.alpha(Colors.accent, 0.55)

                    Text {
                        anchors.centerIn: parent
                        text: "clear"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotifState.clear()
                    }
                }
            }
        }
    }
}
