import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var files: []
    property string currentFile: ""

    readonly property string wallDir: `${Quickshell.env("HOME")}/Pictures/Wallpapers`
    readonly property string wallScript: `${Quickshell.env("HOME")}/.config/hypr/scripts/wallpaper.sh`

    function fileUrl(path: string): string {
        return "file://" + encodeURI(path);
    }

    function prettyName(path: string): string {
        if (!path)
            return "";
        const n = path.split("/").pop().replace(/\.[^.]+$/, "");
        return n.replace(/[-_]+/g, " ");
    }

    function scan(): void {
        scanner.exec(["find", root.wallDir, "(", "-name", ".git", "-o", "-name", "current", ")", "-prune", "-o", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", ")", "-print"]);
        currentReader.exec(["readlink", "-f", `${root.wallDir}/current`]);
    }

    Process {
        id: scanner
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(s => s.length > 0);
                lines.sort((a, b) => a.split("/").pop().localeCompare(b.split("/").pop()));
                root.files = lines;
            }
        }
    }

    Process {
        id: currentReader
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.currentFile = text.trim();
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.wallpaper
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            aboveWindows: true

            readonly property int cardW: Math.min(820, Math.floor(width * 0.5))
            readonly property int cardH: Math.min(500, Math.floor(height * 0.56))
            readonly property string currentPath: {
                if (carousel.currentIndex >= 0 && carousel.currentIndex < root.files.length)
                    return root.files[carousel.currentIndex];
                return "";
            }
            readonly property bool currentGif: currentPath.toLowerCase().endsWith(".gif")

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                if (visible) {
                    root.scan();
                    keySink.forceActiveFocus();
                }
            }

            function jumpToCurrent(): void {
                const i = root.files.indexOf(root.currentFile);
                carousel.currentIndex = i >= 0 ? i : 0;
            }

            function apply(path: string): void {
                if (!path)
                    return;
                OverlayState.close();
                Quickshell.execDetached(["bash", root.wallScript, "file", path]);
            }

            function applyCurrent(): void {
                win.apply(win.currentPath);
            }

            Connections {
                target: root
                function onFilesChanged(): void {
                    win.jumpToCurrent();
                }
                function onCurrentFileChanged(): void {
                    win.jumpToCurrent();
                }
            }

            HyprlandFocusGrab {
                active: win.visible
                windows: [win]
                onCleared: OverlayState.close()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.background, 0.42)

                MouseArea {
                    anchors.fill: parent
                    onClicked: OverlayState.close()
                }
            }

            Item {
                id: keySink
                anchors.fill: parent
                focus: win.visible

                Keys.onEscapePressed: OverlayState.close()
                Keys.onReturnPressed: win.applyCurrent()
                Keys.onEnterPressed: win.applyCurrent()
                Keys.onLeftPressed: carousel.decrementCurrentIndex()
                Keys.onRightPressed: carousel.incrementCurrentIndex()
                Keys.onUpPressed: carousel.decrementCurrentIndex()
                Keys.onDownPressed: carousel.incrementCurrentIndex()

                WheelHandler {
                    onWheel: event => {
                        if (event.angleDelta.y > 0 || event.angleDelta.x < 0)
                            carousel.decrementCurrentIndex();
                        else
                            carousel.incrementCurrentIndex();
                        event.accepted = true;
                    }
                }
            }

            PathView {
                id: carousel
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -36
                height: win.cardH + 48
                model: root.files
                pathItemCount: Math.min(7, count)
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                highlightRangeMode: PathView.StrictlyEnforceRange
                highlightMoveDuration: 280
                flickDeceleration: 1200
                clip: false

                path: Path {
                    startX: 0
                    startY: carousel.height / 2
                    PathAttribute {
                        name: "zOrder"
                        value: 0
                    }
                    PathAttribute {
                        name: "itemScale"
                        value: 0.62
                    }
                    PathAttribute {
                        name: "itemOpacity"
                        value: 0.38
                    }
                    PathAttribute {
                        name: "rot"
                        value: 58
                    }

                    PathLine {
                        x: carousel.width * 0.5
                        y: carousel.height / 2
                    }
                    PathAttribute {
                        name: "zOrder"
                        value: 200
                    }
                    PathAttribute {
                        name: "itemScale"
                        value: 1
                    }
                    PathAttribute {
                        name: "itemOpacity"
                        value: 1
                    }
                    PathAttribute {
                        name: "rot"
                        value: 0
                    }

                    PathLine {
                        x: carousel.width
                        y: carousel.height / 2
                    }
                    PathAttribute {
                        name: "zOrder"
                        value: 0
                    }
                    PathAttribute {
                        name: "itemScale"
                        value: 0.62
                    }
                    PathAttribute {
                        name: "itemOpacity"
                        value: 0.38
                    }
                    PathAttribute {
                        name: "rot"
                        value: -58
                    }
                }

                delegate: Item {
                    id: card
                    required property var modelData
                    required property int index
                    width: win.cardW
                    height: win.cardH
                    z: PathView.zOrder
                    scale: PathView.itemScale
                    opacity: PathView.itemOpacity
                    visible: PathView.onPath

                    readonly property bool selected: PathView.isCurrentItem
                    readonly property real tilt: PathView.rot
                    readonly property bool gif: `${modelData}`.toLowerCase().endsWith(".gif")

                    transform: Rotation {
                        origin.x: card.tilt > 0 ? card.width : (card.tilt < 0 ? 0 : card.width / 2)
                        origin.y: card.height / 2
                        axis {
                            x: 0
                            y: 1
                            z: 0
                        }
                        angle: card.tilt
                    }

                    Rectangle {
                        visible: card.selected
                        anchors.fill: parent
                        anchors.margins: -10
                        radius: 18
                        color: Qt.alpha(Colors.accent, 0.22)
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: "#050508"
                        border.width: card.selected ? 2 : 1
                        border.color: card.selected ? Colors.accent : Qt.alpha(Colors.foreground, 0.18)
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: root.fileUrl(modelData)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            sourceSize.width: 960
                            sourceSize.height: 540
                        }

                        AnimatedImage {
                            visible: card.selected && card.gif
                            anchors.fill: parent
                            source: card.selected && card.gif ? root.fileUrl(modelData) : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            playing: card.selected && OverlayState.wallpaper
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: !card.selected
                            color: Qt.alpha(Colors.background, 0.38)
                        }

                        Rectangle {
                            visible: card.gif && !card.selected
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            width: 34
                            height: 16
                            radius: 3
                            color: Colors.accent

                            Text {
                                anchors.centerIn: parent
                                text: "GIF"
                                color: Colors.background
                                font.family: Colors.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.selected)
                                win.apply(modelData);
                            else
                                carousel.currentIndex = card.index;
                        }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: carousel.bottom
                anchors.topMargin: 8
                text: root.files.length ? root.prettyName(win.currentPath) : "no wallpapers"
                color: Colors.foreground
                font.family: Colors.fontFamily
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 28
                visible: root.files.length > 0
                text: `${carousel.currentIndex + 1}  /  ${root.files.length}   ·   enter set   ·   esc`
                color: Colors.color8
                font.family: Colors.fontFamily
                font.pixelSize: 12
            }

            Text {
                anchors.verticalCenter: carousel.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 28
                text: "‹"
                color: Qt.alpha(Colors.foreground, 0.55)
                font.pixelSize: 42
                visible: root.files.length > 1

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    cursorShape: Qt.PointingHandCursor
                    onClicked: carousel.decrementCurrentIndex()
                }
            }

            Text {
                anchors.verticalCenter: carousel.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 28
                text: "›"
                color: Qt.alpha(Colors.foreground, 0.55)
                font.pixelSize: 42
                visible: root.files.length > 1

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    cursorShape: Qt.PointingHandCursor
                    onClicked: carousel.incrementCurrentIndex()
                }
            }
        }
    }
}
