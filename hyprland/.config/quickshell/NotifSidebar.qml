import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "modules"
import "Components"

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
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            property bool grab: false

            readonly property int pane: Theme.panelWidth(modelData.width)
            readonly property int inset: Theme.space.lg

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
                strength: 0.32
                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Card {
                anchors.right: parent.right
                anchors.rightMargin: win.inset
                anchors.top: parent.top
                anchors.topMargin: Theme.space.lg
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.space.lg
                width: win.pane
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
                    spacing: Theme.space.sm

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Notifications"
                            color: Theme.colors.text
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.title
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                        Text {
                            text: Theme.icons.close
                            color: Theme.colors.textMuted
                            font.family: Theme.font.icon
                            font.pixelSize: Theme.type.icon
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                cursorShape: Qt.PointingHandCursor
                                onClicked: OverlayState.close()
                            }
                        }
                    }

                    Text {
                        text: NotifState.items.length ? `${NotifState.items.length} in history` : "Nothing yet"
                        color: Theme.colors.textMuted
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption
                    }

                    ListView {
                        id: list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: Theme.space.sm
                        boundsBehavior: Flickable.StopAtBounds
                        model: NotifState.items

                        Column {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            spacing: Theme.space.sm
                            Mascot {
                                anchors.horizontalCenter: parent.horizontalCenter
                                fileName: "empty.png"
                                maxH: 72
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "You're all caught up"
                                color: Theme.colors.textMuted
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.body
                            }
                        }

                        delegate: Card {
                            id: card
                            required property var modelData
                            required property int index
                            readonly property var entry: modelData
                            width: list.width
                            implicitHeight: inner.implicitHeight + Theme.space.lg
                            radiusSize: Theme.r.md

                            Column {
                                id: inner
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: Theme.space.md
                                spacing: Theme.space.xs

                                RowLayout {
                                    width: parent.width
                                    spacing: Theme.space.sm

                                    Rectangle {
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        radius: Theme.r.sm
                                        color: Theme.colors.accentSoft
                                        Text {
                                            anchors.centerIn: parent
                                            visible: !(entry.image && entry.image.length) && !(entry.appIcon && entry.appIcon.length)
                                            text: (entry.appName || "?").charAt(0).toUpperCase()
                                            color: Theme.colors.accent
                                            font.family: Theme.font.ui
                                            font.pixelSize: Theme.type.label
                                            font.weight: Font.DemiBold
                                        }
                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 3
                                            visible: entry.image && entry.image.length
                                            source: entry.image || ""
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                        }
                                        IconImage {
                                            anchors.centerIn: parent
                                            visible: !(entry.image && entry.image.length) && entry.appIcon && entry.appIcon.length
                                            implicitSize: 16
                                            source: entry.appIcon ? Quickshell.iconPath(entry.appIcon) : ""
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        Text {
                                            width: parent.width
                                            text: entry.appName || "system"
                                            color: Theme.colors.textMuted
                                            font.family: Theme.font.ui
                                            font.pixelSize: Theme.type.caption
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            width: parent.width
                                            visible: entry.summary && entry.summary.length
                                            text: entry.summary
                                            color: Theme.colors.text
                                            font.family: Theme.font.ui
                                            font.pixelSize: Theme.type.body
                                            font.weight: Font.DemiBold
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        text: NotifState.timeAgo(entry.time)
                                        color: Theme.colors.textMuted
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.caption
                                    }
                                }

                                Text {
                                    width: parent.width
                                    visible: entry.body && entry.body.length
                                    text: entry.body
                                    color: Theme.colors.textSecondary
                                    font.family: Theme.font.ui
                                    font.pixelSize: Theme.type.caption
                                    textFormat: Text.StyledText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                width: 28
                                height: 28
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NotifState.removeAt(card.index)
                                Text {
                                    anchors.centerIn: parent
                                    text: Theme.icons.close
                                    color: Theme.colors.textMuted
                                    font.family: Theme.font.icon
                                    font.pixelSize: Theme.type.caption
                                }
                            }
                        }
                    }

                    Surface {
                        visible: NotifState.items.length > 0
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 96
                        implicitHeight: 32
                        radiusSize: Theme.r.pill
                        color: Theme.colors.accentSoft
                        Text {
                            anchors.centerIn: parent
                            text: "Clear all"
                            color: Theme.colors.accent
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.label
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotifState.clear()
                        }
                    }
                }
            }
        }
    }
}
