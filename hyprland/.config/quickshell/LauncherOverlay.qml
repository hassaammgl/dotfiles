import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.launcher
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            readonly property int cell: 118
            readonly property int colCount: 6
            readonly property var apps: {
                const q = search.text.trim().toLowerCase();
                const all = DesktopEntries.applications.values;
                const out = [];
                for (let i = 0; i < all.length; i++) {
                    const a = all[i];
                    if (a.noDisplay || !a.name)
                        continue;
                    if (!q) {
                        out.push(a);
                        continue;
                    }
                    const keys = (a.keywords || []).join(" ");
                    const blob = `${a.name} ${a.genericName} ${a.comment} ${a.id} ${keys}`.toLowerCase();
                    if (blob.includes(q))
                        out.push(a);
                }
                out.sort((a, b) => a.name.localeCompare(b.name));
                return out.slice(0, 36);
            }
            readonly property var currentApp: {
                const i = grid.currentIndex;
                if (i >= 0 && i < win.apps.length)
                    return win.apps[i];
                return null;
            }

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                if (visible) {
                    search.text = "";
                    grid.currentIndex = 0;
                    search.forceActiveFocus();
                }
            }

            function launch(entry: var): void {
                if (!entry)
                    return;
                entry.execute();
                OverlayState.close();
            }

            function launchCurrent(): void {
                win.launch(win.currentApp);
            }

            function moveSel(dx: int, dy: int): void {
                const count = grid.count;
                if (count === 0)
                    return;
                const c = Math.max(1, Math.floor(grid.width / grid.cellWidth));
                let i = grid.currentIndex;
                if (i < 0)
                    i = 0;
                i += dx + dy * c;
                if (i < 0)
                    i = 0;
                if (i > count - 1)
                    i = count - 1;
                grid.currentIndex = i;
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
                id: stage
                anchors.centerIn: parent
                width: win.cell * win.colCount
                spacing: 22
                opacity: win.visible ? 1 : 0
                scale: win.visible ? 1 : 0.96
                transformOrigin: Item.Center

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
                        text: `${Time.weekday}  ·  ${Time.day} ${Time.month}`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${Time.hour}:${Time.minute} ${Time.ampm.toLowerCase()}`
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 34
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(420, stage.width)
                    height: 48
                    radius: 24
                    color: Qt.alpha(Colors.color0, 0.72)
                    border.width: 1
                    border.color: Qt.alpha(Colors.accent, search.activeFocus ? 0.7 : 0.28)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 10

                        Text {
                            text: ""
                            color: Colors.accent
                            font.family: Colors.fontFamily
                            font.pixelSize: 14
                        }

                        TextField {
                            id: search
                            Layout.fillWidth: true
                            placeholderText: "find"
                            color: Colors.foreground
                            placeholderTextColor: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 15
                            background: Item {}
                            selectByMouse: true
                            onTextChanged: grid.currentIndex = 0
                            Keys.onEscapePressed: OverlayState.close()
                            Keys.onReturnPressed: win.launchCurrent()
                            Keys.onEnterPressed: win.launchCurrent()
                            Keys.onLeftPressed: event => {
                                win.moveSel(-1, 0);
                                event.accepted = true;
                            }
                            Keys.onRightPressed: event => {
                                win.moveSel(1, 0);
                                event.accepted = true;
                            }
                            Keys.onUpPressed: event => {
                                win.moveSel(0, -1);
                                event.accepted = true;
                            }
                            Keys.onDownPressed: event => {
                                win.moveSel(0, 1);
                                event.accepted = true;
                            }
                        }
                    }
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    width: parent.width

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.currentApp ? win.currentApp.name : (search.text.length ? "nothing" : "apps")
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.currentApp ? (win.currentApp.comment || win.currentApp.genericName || "enter to open") : "type to search"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        width: Math.min(420, stage.width)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                GridView {
                    id: grid
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: win.cell * win.colCount
                    height: cellHeight * 3
                    cellWidth: win.cell
                    cellHeight: 112
                    clip: true
                    interactive: true
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    model: win.apps

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            id: tile
                            anchors.centerIn: parent
                            width: 96
                            height: 96
                            radius: 22
                            color: grid.currentIndex === index ? Qt.alpha(Colors.accent, 0.32) : (hover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : Qt.alpha(Colors.color0, 0.22))
                            border.width: grid.currentIndex === index ? 1 : 0
                            border.color: Qt.alpha(Colors.accent, 0.9)
                            scale: grid.currentIndex === index ? 1.06 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 90
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                IconImage {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    implicitSize: 42
                                    source: Quickshell.iconPath(modelData.icon || "application-x-executable")
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 84
                                    text: modelData.name
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: grid.currentIndex = index
                            onClicked: win.launch(modelData)
                        }
                    }
                }
            }
        }
    }
}
