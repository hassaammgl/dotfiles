pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string phase: "pick"
    property string lastPath: `${Quickshell.env("HOME")}/.cache/quickshell/last-screenshot.png`
    property string pendingMode: ""
    property int lastCode: 0
    property int tick: 0

    readonly property string script: `${Quickshell.env("HOME")}/.config/hypr/scripts/screenshot-capture.sh`
    readonly property string shotDir: `${Quickshell.env("HOME")}/Pictures/Screenshots`

    function resetPick(): void {
        phase = "pick";
        pendingMode = "";
        capture.running = false;
    }

    function start(mode: string): void {
        pendingMode = mode;
        OverlayState.screenshot = false;
        delay.restart();
    }

    function copy(): void {
        if (phase !== "preview")
            return;
        Quickshell.execDetached(["bash", "-c", "wl-copy --type image/png < \"$1\" && notify-send Screenshot Copied", "ss", lastPath]);
        OverlayState.close();
    }

    function save(): void {
        if (phase !== "preview")
            return;
        Quickshell.execDetached(["bash", "-c", "mkdir -p \"$1\" && f=\"$1/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png\" && cp -- \"$2\" \"$f\" && notify-send Screenshot \"Saved $(basename \"$f\")\"", "ss", shotDir, lastPath]);
        OverlayState.close();
    }

    function both(): void {
        if (phase !== "preview")
            return;
        Quickshell.execDetached(["bash", "-c", "wl-copy --type image/png < \"$2\" && mkdir -p \"$1\" && f=\"$1/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png\" && cp -- \"$2\" \"$f\" && notify-send Screenshot \"Copied + saved $(basename \"$f\")\"", "ss", shotDir, lastPath]);
        OverlayState.close();
    }

    Timer {
        id: delay
        interval: 180
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["mkdir", "-p", `${Quickshell.env("HOME")}/.cache/quickshell`]);
            capture.exec(["bash", root.script, root.pendingMode, root.lastPath]);
        }
    }

    Process {
        id: capture
        onExited: (exitCode, exitStatus) => {
            root.lastCode = exitCode;
            if (exitCode === 0) {
                root.phase = "preview";
                root.tick++;
                OverlayState.showScreenshot();
            } else {
                root.phase = "pick";
                if (exitCode !== 2)
                    Quickshell.execDetached(["notify-send", "-u", "critical", "Screenshot", "Capture failed"]);
                OverlayState.showScreenshot();
            }
        }
    }
}
