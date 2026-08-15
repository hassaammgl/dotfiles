import Quickshell
import Quickshell.Io

Scope {
    Bar {}
    LauncherOverlay {}
    PowerOverlay {}

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            OverlayState.toggleLauncher();
        }

        function show(): void {
            OverlayState.power = false;
            OverlayState.launcher = true;
        }

        function hide(): void {
            OverlayState.launcher = false;
        }
    }

    IpcHandler {
        target: "power"

        function toggle(): void {
            OverlayState.togglePower();
        }

        function show(): void {
            OverlayState.launcher = false;
            OverlayState.power = true;
        }

        function hide(): void {
            OverlayState.power = false;
        }
    }
}
