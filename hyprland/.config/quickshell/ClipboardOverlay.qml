import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    property var items: []

    function refresh(): void {
        listProc.exec(["cliphist", "list"]);
    }

    function parseList(text: string) {
        const lines = text.split("\n").filter(s => s.length > 0);
        const out = [];
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const tab = line.indexOf("\t");
            const preview = tab >= 0 ? line.slice(tab + 1) : line;
            const compact = preview.replace(/\s+/g, " ").trim();
            out.push({
                "line": line,
                "preview": compact.length ? compact : "(empty)",
                "image": /\[\[\s*binary data/i.test(preview)
            });
        }
        return out;
    }

    Process {
        id: listProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.items = root.parseList(text)
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.clipboard
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            readonly property bool del: OverlayState.clipboardDelete
            readonly property color tint: del ? Colors.color1 : Colors.accent
            readonly property var filtered: {
                const q = search.text.trim().toLowerCase();
                const src = root.items;
                if (!q)
                    return src;
                return src.filter(it => it.preview.toLowerCase().includes(q));
            }
            readonly property var currentItem: {
                const i = list.currentIndex;
                if (i >= 0 && i < win.filtered.length)
                    return win.filtered[i];
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
                    list.currentIndex = 0;
                    root.refresh();
                    search.forceActiveFocus();
                }
            }

            Connections {
                target: root
                function onItemsChanged(): void {
                    list.currentIndex = 0;
                }
            }

            function copy(item: var): void {
                if (!item)
                    return;
                OverlayState.close();
                Quickshell.execDetached(["bash", "-c", "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "clip", item.line]);
            }

            function remove(item: var): void {
                if (!item)
                    return;
                Quickshell.execDetached(["bash", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "clip", item.line]);
                root.items = root.items.filter(it => it.line !== item.line);
                if (list.currentIndex >= win.filtered.length)
                    list.currentIndex = Math.max(0, win.filtered.length - 1);
            }

            function activate(): void {
                if (win.del)
                    win.remove(win.currentItem);
                else
                    win.copy(win.currentItem);
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
                width: Math.min(640, parent.width - 64)
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
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.del ? "clipboard" : "history"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.del ? "delete" : "clipboard"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 28
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(420, stage.width)
                    height: 44
                    radius: 22
                    color: Qt.alpha(Colors.color0, 0.72)
                    border.width: 1
                    border.color: Qt.alpha(win.tint, search.activeFocus ? 0.7 : 0.28)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 10

                        Text {
                            text: ""
                            color: win.tint
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
                            onTextChanged: list.currentIndex = 0
                            Keys.onEscapePressed: OverlayState.close()
                            Keys.onReturnPressed: win.activate()
                            Keys.onEnterPressed: win.activate()
                            Keys.onUpPressed: event => {
                                list.decrementCurrentIndex();
                                event.accepted = true;
                            }
                            Keys.onDownPressed: event => {
                                list.incrementCurrentIndex();
                                event.accepted = true;
                            }
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier)) {
                                    win.remove(win.currentItem);
                                    event.accepted = true;
                                    return;
                                }
                                if (event.key === Qt.Key_Delete && search.text.length === 0) {
                                    win.remove(win.currentItem);
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: list
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.min(460, win.height * 0.55)
                    clip: true
                    spacing: 8
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    model: win.filtered

                    Text {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: search.text.length ? "nothing" : "empty"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                    }

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: list.width
                        height: 48
                        radius: 12
                        color: list.currentIndex === index ? Qt.alpha(win.tint, 0.32) : Qt.alpha(Colors.color0, 0.4)
                        border.width: list.currentIndex === index ? 1 : 0
                        border.color: Qt.alpha(win.tint, 0.9)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            Text {
                                text: modelData.image ? "" : ""
                                color: list.currentIndex === index ? win.tint : Colors.color8
                                font.family: Colors.fontFamily
                                font.pixelSize: 14
                            }

                            Text {
                                text: modelData.preview
                                color: Colors.foreground
                                font.family: Colors.fontFamily
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: list.currentIndex = index
                            onClicked: {
                                if (win.del)
                                    win.remove(modelData);
                                else
                                    win.copy(modelData);
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: list.count > 0
                    text: win.del ? "enter delete   ·   esc" : "enter copy   ·   del remove   ·   esc"
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 12
                }
            }
        }
    }
}
