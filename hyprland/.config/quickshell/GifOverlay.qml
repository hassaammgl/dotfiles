import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var files: []
    property int thumbsTick: 0
    property string phase: "pick"
    property string convertLog: ""
    property string lastVideo: ""
    property string lastGif: ""
    property string infoText: ""

    readonly property string clipDir: `${Quickshell.env("HOME")}/Pictures/WallpaperVideos`
    readonly property string wallDir: `${Quickshell.env("HOME")}/Pictures/Wallpapers`
    readonly property string thumbDir: `${Quickshell.env("HOME")}/.cache/quickshell/gif-thumbs`
    readonly property string convertScript: `${Quickshell.env("HOME")}/.config/hypr/scripts/video-to-gif.sh`
    readonly property string thumbScript: `${Quickshell.env("HOME")}/.config/hypr/scripts/gif-thumbs.sh`
    readonly property string wallScript: `${Quickshell.env("HOME")}/.config/hypr/scripts/wallpaper.sh`
    readonly property bool busy: phase === "converting"

    function fileUrl(path: string): string {
        return "file://" + encodeURI(path);
    }

    function prettyName(path: string): string {
        if (!path)
            return "";
        const n = path.split("/").pop().replace(/\.[^.]+$/, "");
        return n.replace(/[-_]+/g, " ");
    }

    function gifFor(path: string): string {
        const n = path.split("/").pop().replace(/\.[^.]+$/, "");
        return `${root.wallDir}/${n}.gif`;
    }

    function thumbFor(path: string): string {
        const n = path.split("/").pop();
        return `${root.thumbDir}/${n}.jpg`;
    }

    function reset(): void {
        convertProc.running = false;
        phase = "pick";
        convertLog = "";
        lastVideo = "";
        lastGif = "";
        infoText = "";
    }

    function scan(): void {
        Quickshell.execDetached(["mkdir", "-p", root.clipDir, root.thumbDir, root.wallDir]);
        scanner.exec(["find", root.clipDir, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.mp4", "-o", "-iname", "*.webm", "-o", "-iname", "*.mkv", "-o", "-iname", "*.mov", "-o", "-iname", "*.m4v", "-o", "-iname", "*.avi", ")", "-print"]);
    }

    function startConvert(path: string, apply: bool): void {
        if (!path || root.busy)
            return;
        lastVideo = path;
        lastGif = gifFor(path);
        convertLog = "";
        phase = "converting";
        const cmd = ["bash", root.convertScript];
        if (apply)
            cmd.push("--set");
        cmd.push(path);
        convertProc.exec(cmd);
    }

    function setWallpaper(): void {
        if (!lastGif)
            return;
        OverlayState.close();
        Quickshell.execDetached(["bash", root.wallScript, "file", lastGif]);
    }

    function deleteSource(): void {
        if (!lastVideo)
            return;
        Quickshell.execDetached(["rm", "-f", "--", lastVideo]);
        Quickshell.execDetached(["notify-send", "Video → GIF", `Deleted source: ${lastVideo.split("/").pop()}`]);
        reset();
        scan();
    }

    Connections {
        target: OverlayState
        function onGifChanged(): void {
            if (!OverlayState.gif)
                root.reset();
        }
    }

    Process {
        id: scanner
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(s => s.length > 0);
                lines.sort((a, b) => a.split("/").pop().localeCompare(b.split("/").pop()));
                root.files = lines;
                if (lines.length)
                    thumbs.exec(["bash", root.thumbScript].concat(lines));
            }
        }
    }

    Process {
        id: thumbs
        onExited: root.thumbsTick++
    }

    Process {
        id: probe
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const dur = parseFloat(lines[0]);
                const size = parseInt(lines[1], 10);
                let out = "";
                if (!isNaN(dur) && dur > 0)
                    out += dur >= 10 ? `${Math.round(dur)}s` : `${dur.toFixed(1)}s`;
                if (!isNaN(size) && size > 0) {
                    const mb = size / (1024 * 1024);
                    const pretty = mb >= 10 ? `${Math.round(mb)} MB` : `${mb.toFixed(1)} MB`;
                    out += out ? `  ·  ${pretty}` : pretty;
                }
                if (dur > 20)
                    out += "  ·  trim 20s";
                root.infoText = out;
            }
        }
    }

    Process {
        id: convertProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.convertLog = text.trim()
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (!root.convertLog.length)
                    root.convertLog = text.trim();
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.phase = exitCode === 0 ? "done" : "error";
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: OverlayState.gif
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
            readonly property bool picking: root.phase === "pick"

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            onVisibleChanged: {
                if (visible) {
                    root.reset();
                    root.scan();
                    keySink.forceActiveFocus();
                }
            }

            onCurrentPathChanged: {
                root.infoText = "";
                if (currentPath)
                    probe.exec(["ffprobe", "-v", "error", "-show_entries", "format=duration,size", "-of", "default=noprint_wrappers=1:nokey=1", currentPath]);
            }

            HyprlandFocusGrab {
                active: win.visible
                windows: [win]
                onCleared: {
                    if (!root.busy)
                        OverlayState.close();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.background, 0.42)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!root.busy)
                            OverlayState.close();
                    }
                }
            }

            Item {
                id: keySink
                anchors.fill: parent
                focus: win.visible
                enabled: win.visible

                Keys.onEscapePressed: event => {
                    if (root.busy) {
                        convertProc.running = false;
                        root.phase = "pick";
                    } else {
                        OverlayState.close();
                    }
                    event.accepted = true;
                }
                Keys.onReturnPressed: event => win.handleEnter(event)
                Keys.onEnterPressed: event => win.handleEnter(event)
                Keys.onLeftPressed: event => {
                    if (win.picking)
                        carousel.decrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onRightPressed: event => {
                    if (win.picking)
                        carousel.incrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onUpPressed: event => {
                    if (win.picking)
                        carousel.decrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onDownPressed: event => {
                    if (win.picking)
                        carousel.incrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onPressed: event => {
                    if (root.phase === "done" && event.key === Qt.Key_D) {
                        root.deleteSource();
                        event.accepted = true;
                    }
                }

                WheelHandler {
                    enabled: win.picking
                    onWheel: event => {
                        if (event.angleDelta.y > 0 || event.angleDelta.x < 0)
                            carousel.decrementCurrentIndex();
                        else
                            carousel.incrementCurrentIndex();
                        event.accepted = true;
                    }
                }
            }

            function handleEnter(event): void {
                if (win.picking)
                    root.startConvert(win.currentPath, !!(event.modifiers & Qt.ShiftModifier));
                else if (root.phase === "done")
                    root.setWallpaper();
                else if (root.phase === "error")
                    root.phase = "pick";
                event.accepted = true;
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
                opacity: win.picking ? 1 : 0.22
                interactive: win.picking
                enabled: win.picking

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
                    readonly property string thumb: `${root.fileUrl(root.thumbFor(modelData))}?${root.thumbsTick}`

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
                            id: thumbImg
                            anchors.fill: parent
                            source: card.thumb
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            sourceSize.width: 960
                            sourceSize.height: 540
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: !card.selected || thumbImg.status !== Image.Ready
                            color: Qt.alpha(Colors.background, thumbImg.status === Image.Ready ? 0.38 : 0.55)
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            width: 48
                            height: 16
                            radius: 3
                            color: Colors.accent

                            Text {
                                anchors.centerIn: parent
                                text: "CLIP"
                                color: Colors.background
                                font.family: Colors.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: win.picking
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.selected)
                                root.startConvert(modelData, false);
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
                visible: win.picking
                text: root.files.length ? root.prettyName(win.currentPath) : "no clips"
                color: Colors.foreground
                font.family: Colors.fontFamily
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: carousel.bottom
                anchors.topMargin: 44
                visible: win.picking && root.files.length > 0 && root.infoText.length > 0
                text: root.infoText
                color: Colors.color8
                font.family: Colors.fontFamily
                font.pixelSize: 13
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 28
                visible: win.picking && root.files.length > 0
                text: `${carousel.currentIndex + 1}  /  ${root.files.length}   ·   enter convert   ·   shift+enter set   ·   esc`
                color: Colors.color8
                font.family: Colors.fontFamily
                font.pixelSize: 12
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 28
                visible: win.picking && root.files.length === 0
                text: `drop mp4/webm in  ${root.clipDir}`
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
                visible: win.picking && root.files.length > 1

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
                visible: win.picking && root.files.length > 1

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    cursorShape: Qt.PointingHandCursor
                    onClicked: carousel.incrementCurrentIndex()
                }
            }

            Rectangle {
                visible: !win.picking
                anchors.centerIn: parent
                width: Math.min(520, parent.width - 80)
                height: Math.min(280, parent.height - 80)
                radius: 16
                color: Qt.alpha(Colors.background, 0.92)
                border.width: 1
                border.color: Qt.alpha(Colors.foreground, 0.16)

                MouseArea {
                    anchors.fill: parent
                }

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 14

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.phase === "converting" ? "converting…" : (root.phase === "done" ? "GIF ready" : "convert failed")
                        color: root.phase === "error" ? Colors.color1 : Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: root.convertLog.length > 0
                        text: root.convertLog.split("\n").slice(-6).join("\n")
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10
                        visible: root.phase === "done"

                        Repeater {
                            model: [
                                {
                                    "id": "set",
                                    "label": "set wallpaper"
                                },
                                {
                                    "id": "del",
                                    "label": "delete source"
                                },
                                {
                                    "id": "close",
                                    "label": "close"
                                }
                            ]

                            Rectangle {
                                required property var modelData
                                width: 148
                                height: 36
                                radius: 8
                                color: Qt.alpha(Colors.accent, modelData.id === "set" ? 0.85 : 0.28)

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: Colors.foreground
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.id === "set")
                                            root.setWallpaper();
                                        else if (modelData.id === "del")
                                            root.deleteSource();
                                        else
                                            OverlayState.close();
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.phase === "done"
                        text: "enter set   ·   d delete   ·   esc"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.phase === "converting"
                        text: "esc cancel"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.phase === "error"
                        text: "enter back   ·   esc"
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
