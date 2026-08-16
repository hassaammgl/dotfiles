import Quickshell
import Quickshell.Io

Scope {
    Bar {}
    Notifications {}
    LauncherOverlay {}
    PowerOverlay {}
    WallpaperOverlay {}

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            OverlayState.toggleLauncher();
        }

        function show(): void {
            OverlayState.power = false;
            OverlayState.wallpaper = false;
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
            OverlayState.wallpaper = false;
            OverlayState.power = true;
        }

        function hide(): void {
            OverlayState.power = false;
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            OverlayState.toggleWallpaper();
        }

        function show(): void {
            OverlayState.launcher = false;
            OverlayState.power = false;
            OverlayState.wallpaper = true;
        }

        function hide(): void {
            OverlayState.wallpaper = false;
        }
    }
}
