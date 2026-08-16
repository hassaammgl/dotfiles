import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    property bool ignoreClick: false

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property real vol: ready ? sink.audio.volume : 0
    readonly property bool micReady: source !== null && source.ready && source.audio !== null
    readonly property bool micMuted: micReady ? source.audio.muted : false
    readonly property real micVol: micReady ? source.audio.volume : 0

    readonly property var sinks: {
        const out = [];
        for (const n of Pipewire.nodes.values) {
            if (n && n.isSink && !n.isStream)
                out.push(n);
        }
        return out;
    }

    function setVol(next: real): void {
        if (!root.ready)
            return;
        root.sink.audio.muted = false;
        root.sink.audio.volume = Math.max(0, Math.min(1, next));
    }

    function setMic(next: real): void {
        if (!root.micReady)
            return;
        root.source.audio.muted = false;
        root.source.audio.volume = Math.max(0, Math.min(1, next));
    }

    function nodeLabel(n: var): string {
        return n.nickname || n.description || n.name || "output";
    }

    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.sinks).filter(n => n)
    }

    BarButton {
        id: btn
        anchors.centerIn: parent
        active: pop.visible
        icon: {
            if (root.muted || !root.ready || root.vol === 0)
                return "";
            if (root.vol < 0.35)
                return "";
            if (root.vol < 0.7)
                return "";
            return "";
        }
        iconColor: root.muted ? Colors.color8 : Colors.foreground
        onClicked: event => {
            if (root.ignoreClick)
                return;
            if (event.button === Qt.RightButton) {
                if (root.ready)
                    root.sink.audio.muted = !root.sink.audio.muted;
                return;
            }
            pop.visible = !pop.visible;
        }
        onWheel: delta => {
            const step = delta > 0 ? 0.05 : -0.05;
            root.setVol(root.vol + step);
        }
    }

    PopupWindow {
        id: pop

        visible: false
        color: "transparent"
        implicitWidth: 280
        implicitHeight: 320
        grabFocus: true

        anchor {
            item: root
            edges: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            gravity: BarState.edge === "right" ? Edges.Left : (BarState.edge === "top" ? Edges.Bottom : (BarState.edge === "bottom" ? Edges.Top : Edges.Right))
            adjustment: PopupAdjustment.Slide
            margins.left: 10
            margins.right: 10
            margins.top: 10
            margins.bottom: 10
        }

        HyprlandFocusGrab {
            active: pop.visible
            windows: [pop]
            onCleared: {
                pop.visible = false;
                root.ignoreClick = true;
                Qt.callLater(() => {
                    root.ignoreClick = false;
                });
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Colors.background
            border.width: 1
            border.color: Colors.color0
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Sound"
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    Text {
                        text: `${Math.round(root.vol * 100)}%`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: root.ready && !root.muted ? Colors.accent : Colors.color0

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.ready && !root.muted ? parent.width - width - 3 : 3
                            color: Colors.foreground

                            Behavior on x {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.ready)
                                    root.sink.audio.muted = !root.sink.audio.muted;
                            }
                        }
                    }
                }

                PopSlider {
                    Layout.fillWidth: true
                    value: root.vol
                    dimmed: root.muted
                    onApplied: next => root.setVol(next)
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: root.micMuted ? "󰍭" : "󰍬"
                        color: root.micMuted ? Colors.color8 : Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                    }

                    PopSlider {
                        Layout.fillWidth: true
                        value: root.micVol
                        dimmed: root.micMuted
                        onApplied: next => root.setMic(next)
                    }

                    Text {
                        text: `${Math.round(root.micVol * 100)}%`
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                    }
                }

                Text {
                    text: "Output"
                    color: Colors.color8
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.sinks

                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool current: root.sink && modelData && root.sink.id === modelData.id
                        width: ListView.view.width
                        height: 36
                        radius: 10
                        color: current ? Qt.alpha(Colors.accent, 0.22) : (rowHover.containsMouse ? Qt.alpha(Colors.color0, 0.55) : "transparent")

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: root.nodeLabel(modelData)
                            color: Colors.foreground
                            font.family: Colors.fontFamily
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Pipewire.preferredDefaultAudioSink = modelData
                        }
                    }
                }
            }
        }
    }
}
