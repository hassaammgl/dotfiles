import Quickshell
import Quickshell.Io

Scope {
    Bar {}
    Notifications {}
    NotifSidebar {}
    LauncherOverlay {}
    PowerOverlay {}
    WallpaperOverlay {}
    KeybindsOverlay {}

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            OverlayState.toggleLauncher();
        }

        function show(): void {
            OverlayState.power = false;
            OverlayState.wallpaper = false;
            OverlayState.notifs = false;
            OverlayState.keybinds = false;
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
            OverlayState.notifs = false;
            OverlayState.keybinds = false;
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
            OverlayState.notifs = false;
            OverlayState.keybinds = false;
            OverlayState.wallpaper = true;
        }

        function hide(): void {
            OverlayState.wallpaper = false;
        }
    }

    IpcHandler {
        target: "notifs"

        function toggle(): void {
            OverlayState.toggleNotifs();
        }

        function show(): void {
            OverlayState.launcher = false;
            OverlayState.power = false;
            OverlayState.wallpaper = false;
            OverlayState.keybinds = false;
            OverlayState.notifs = true;
        }

        function hide(): void {
            OverlayState.notifs = false;
        }
    }

    IpcHandler {
        target: "keybinds"

        function toggle(): void {
            OverlayState.toggleKeybinds();
        }

        function show(): void {
            OverlayState.launcher = false;
            OverlayState.power = false;
            OverlayState.wallpaper = false;
            OverlayState.notifs = false;
            OverlayState.keybinds = true;
        }

        function hide(): void {
            OverlayState.keybinds = false;
        }
    }
}
