import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    property var all: []

    FileView {
        path: `${Quickshell.env("HOME")}/.config/quickshell/emojis.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.all = JSON.parse(text());
            } catch (e) {
                root.all = [];
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.emoji
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            readonly property int cell: 72
            readonly property int colCount: 10
            readonly property var items: {
                const q = search.text.trim().toLowerCase();
                const src = root.all;
                if (!q)
                    return src.slice(0, 80);
                const out = [];
                for (let i = 0; i < src.length; i++) {
                    const it = src[i];
                    if (`${it.g} ${it.n} ${it.k}`.toLowerCase().includes(q))
                        out.push(it);
                    if (out.length >= 80)
                        break;
                }
                return out;
            }
            readonly property var currentItem: {
                const i = grid.currentIndex;
                if (i >= 0 && i < win.items.length)
                    return win.items[i];
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

            function pick(item: var): void {
                if (!item || !item.g)
                    return;
                OverlayState.close();
                Quickshell.execDetached(["wl-copy", item.g]);
            }

            function pickCurrent(): void {
                win.pick(win.currentItem);
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
                spacing: 18
                opacity: win.visible ? 1 : 0
                scale: win.visible ? 1 : 0.96

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
                        text: "emoji"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.currentItem ? win.currentItem.g : "pick"
                        color: Colors.foreground
                        font.family: "Noto Color Emoji"
                        font.pixelSize: 34
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: win.currentItem ? win.currentItem.n : (search.text.length ? "nothing" : "type to search")
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(420, stage.width)
                    height: 44
                    radius: 22
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
                            Keys.onReturnPressed: win.pickCurrent()
                            Keys.onEnterPressed: win.pickCurrent()
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

                GridView {
                    id: grid
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: win.cell * win.colCount
                    height: cellHeight * 4
                    cellWidth: win.cell
                    cellHeight: win.cell
                    clip: true
                    interactive: true
                    boundsBehavior: Flickable.StopAtBounds
                    highlightFollowsCurrentItem: true
                    model: win.items

                    Text {
                        anchors.centerIn: parent
                        visible: grid.count === 0
                        text: "nothing"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                    }

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.centerIn: parent
                            width: 60
                            height: 60
                            radius: 16
                            color: grid.currentIndex === index ? Qt.alpha(Colors.accent, 0.32) : (hover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : Qt.alpha(Colors.color0, 0.22))
                            border.width: grid.currentIndex === index ? 1 : 0
                            border.color: Qt.alpha(Colors.accent, 0.9)
                            scale: grid.currentIndex === index ? 1.08 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 90
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.g
                                font.family: "Noto Color Emoji"
                                font.pixelSize: 28
                            }
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: grid.currentIndex = index
                            onClicked: win.pick(modelData)
                        }
                    }
                }
            }
        }
    }
}
