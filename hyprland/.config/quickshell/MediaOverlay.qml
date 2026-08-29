import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import "Components"

Scope {
    id: root

    property var levels: []

    readonly property string cavaConf: `${Quickshell.env("HOME")}/.config/quickshell/cava-media.conf`

    Connections {
        target: OverlayState
        function onMediaChanged(): void {
            if (!OverlayState.media) {
                root.levels = [];
                root.tick = 0;
                root.maxLevel = 1;
            }
        }
    }

    property int tick: 0
    property real maxLevel: 1

    Process {
        running: OverlayState.media
        command: ["stdbuf", "-oL", "cava", "-p", root.cavaConf]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.split(";");
                const next = [];
                let peak = 1;
                for (let i = 0; i < parts.length; i++) {
                    const n = parseInt(parts[i], 10);
                    if (isNaN(n))
                        continue;
                    const v = Math.max(0, Math.min(100, n));
                    next.push(v);
                    if (v > peak)
                        peak = v;
                }
                if (next.length) {
                    root.maxLevel = peak;
                    root.levels = next;
                    root.tick++;
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.media
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            property int current: 1
            readonly property var actions: [
                {
                    "id": "prev",
                    "name": "Previous",
                    "icon": "",
                    "tint": Colors.color6,
                    "ok": MediaState.ready && MediaState.player && MediaState.player.canGoPrevious
                },
                {
                    "id": "play",
                    "name": MediaState.playing ? "Pause" : "Play",
                    "icon": MediaState.playing ? "" : "",
                    "tint": Colors.accent,
                    "ok": MediaState.ready && MediaState.player && MediaState.player.canTogglePlaying
                },
                {
                    "id": "next",
                    "name": "Next",
                    "icon": "",
                    "tint": Colors.color3,
                    "ok": MediaState.ready && MediaState.player && MediaState.player.canGoNext
                },
                {
                    "id": "stop",
                    "name": "Stop",
                    "icon": "",
                    "tint": Colors.color1,
                    "ok": MediaState.ready && MediaState.player && MediaState.player.canControl
                },
                {
                    "id": "raise",
                    "name": "Open",
                    "icon": "",
                    "tint": Colors.foreground,
                    "ok": MediaState.ready && MediaState.player && MediaState.player.canRaise
                }
            ]
            readonly property var currentAction: win.actions[win.current]

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                if (visible)
                    current = 1;
            }

            function run(id: string): void {
                if (id === "prev")
                    MediaState.prev();
                else if (id === "play")
                    MediaState.toggle();
                else if (id === "next")
                    MediaState.next();
                else if (id === "stop")
                    MediaState.stop();
                else if (id === "raise")
                    MediaState.raise();
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
                sequence: "Space"
                enabled: win.visible
                onActivated: MediaState.toggle()
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

            Timer {
                interval: 1000
                repeat: true
                running: win.visible && MediaState.playing && MediaState.ready && MediaState.player && MediaState.player.positionSupported
                onTriggered: MediaState.player.positionChanged()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.background, 0.55)

                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Item {
                id: vis
                anchors.fill: parent
                enabled: false

                Row {
                    id: cavaRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * 0.72
                    spacing: 4

                    Repeater {
                        model: root.levels.length

                        Rectangle {
                            required property int index
                            readonly property real ratio: {
                                root.tick;
                                return (root.levels[index] || 0) / Math.max(1, root.maxLevel);
                            }
                            width: Math.max(3, (cavaRow.width - Math.max(0, root.levels.length - 1) * cavaRow.spacing) / Math.max(1, root.levels.length))
                            height: Math.max(ratio > 0 ? 8 : 0, vis.height * 0.68 * ratio)
                            anchors.bottom: parent.bottom
                            radius: 3
                            color: Qt.alpha(index % 2 === 0 ? Colors.accent : Colors.secondary, 0.4 + 0.55 * ratio)
                        }
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 28
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
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 120
                    height: 120
                    radius: 16
                    color: Theme.colors.background
                    border.width: 1
                    border.color: Qt.alpha(Colors.foreground, 0.16)
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: MediaState.art
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: MediaState.art.length > 0
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: MediaState.art.length === 0
                        text: ""
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 36
                    }
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: MediaState.identity || "now playing"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 520
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        text: win.currentAction.name
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 28
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 520
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        visible: MediaState.ready
                        text: MediaState.artist.length ? `${MediaState.title}  ·  ${MediaState.artist}` : MediaState.title
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
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
                            width: 88
                            height: 88

                            Rectangle {
                                anchors.centerIn: parent
                                width: win.current === index ? 84 : 72
                                height: width
                                radius: width / 2
                                opacity: modelData.ok ? 1 : 0.35
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

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    visible: MediaState.ready && MediaState.length > 0
                    width: 420

                    Slider {
                        width: parent.width
                        value: MediaState.progress
                        onApplied: next => MediaState.seekRatio(next)
                    }

                    Row {
                        width: parent.width

                        Text {
                            text: MediaState.fmt(MediaState.position)
                            color: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 11
                        }

                        Item {
                            width: parent.width - 80
                            height: 1
                        }

                        Text {
                            text: MediaState.fmt(MediaState.length)
                            color: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
