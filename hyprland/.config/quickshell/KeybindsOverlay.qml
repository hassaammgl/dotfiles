import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    property string raw: ""

    readonly property var sections: {
        const out = [];
        let cur = null;
        const lines = root.raw.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line)
                continue;
            const m = line.match(/^(\S.*?\S)\s{2,}(.+)$/);
            const looksBind = m && /SUPER|ALT|CTRL|SHIFT|XF86|Print|LMB|RMB/.test(m[1]);
            if (looksBind) {
                if (!cur) {
                    cur = {
                        "name": "General",
                        "binds": []
                    };
                    out.push(cur);
                }
                cur.binds.push({
                    "keys": m[1],
                    "desc": m[2]
                });
            } else {
                cur = {
                    "name": line.replace(/^[^\w]+/, "").trim() || line,
                    "binds": []
                };
                out.push(cur);
            }
        }
        return out.filter(s => s.binds.length > 0);
    }

    FileView {
        path: `${Quickshell.env("HOME")}/.config/hypr/scripts/keybinds.txt`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.raw = text()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.keybinds
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            readonly property var filtered: {
                const q = search.text.trim().toLowerCase();
                const src = root.sections;
                if (!q)
                    return src;
                const out = [];
                for (let i = 0; i < src.length; i++) {
                    const binds = src[i].binds.filter(b => `${b.keys} ${b.desc} ${src[i].name}`.toLowerCase().includes(q));
                    if (binds.length)
                        out.push({
                            "name": src[i].name,
                            "binds": binds
                        });
                }
                return out;
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
                    search.forceActiveFocus();
                }
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
                        text: "keybinds"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: search.text.length ? "filter" : "cheatsheet"
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
                            Keys.onEscapePressed: OverlayState.close()
                        }
                    }
                }

                ListView {
                    id: list
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.min(460, win.height * 0.55)
                    clip: true
                    spacing: 14
                    boundsBehavior: Flickable.StopAtBounds
                    model: win.filtered

                    Text {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: "nothing"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                    }

                    delegate: Column {
                        required property var modelData
                        width: list.width
                        spacing: 6

                        Text {
                            text: modelData.name
                            color: Colors.accent
                            font.family: Colors.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: modelData.binds

                            Rectangle {
                                required property var modelData
                                width: list.width
                                height: 32
                                radius: 10
                                color: Qt.alpha(Colors.color0, 0.4)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12

                                    Text {
                                        text: modelData.keys
                                        color: Colors.foreground
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 12
                                        Layout.preferredWidth: 220
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.desc
                                        color: Colors.color8
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
