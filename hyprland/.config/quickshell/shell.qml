import Quickshell
import Quickshell.Io

Scope {
    Bar {}
    Notifications {}
    NotifSidebar {}
    LauncherOverlay {}
    PowerOverlay {}
    WallpaperOverlay {}
    GifOverlay {}
    KeybindsOverlay {}
    ClipboardOverlay {}
    EmojiOverlay {}
    LockOverlay {}
    OsdOverlay {}

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            OverlayState.toggleLauncher();
        }

        function show(): void {
            OverlayState.showLauncher();
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
            OverlayState.showPower();
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
            OverlayState.showWallpaper();
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
            OverlayState.showNotifs();
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
            OverlayState.showKeybinds();
        }

        function hide(): void {
            OverlayState.keybinds = false;
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            OverlayState.toggleClipboard(false);
        }

        function toggleDelete(): void {
            OverlayState.toggleClipboard(true);
        }

        function show(): void {
            OverlayState.showClipboard(false);
        }

        function hide(): void {
            OverlayState.clipboard = false;
            OverlayState.clipboardDelete = false;
        }
    }

    IpcHandler {
        target: "emoji"

        function toggle(): void {
            OverlayState.toggleEmoji();
        }

        function show(): void {
            OverlayState.showEmoji();
        }

        function hide(): void {
            OverlayState.emoji = false;
        }
    }

    IpcHandler {
        target: "gif"

        function toggle(): void {
            OverlayState.toggleGif();
        }

        function show(): void {
            OverlayState.showGif();
        }

        function hide(): void {
            OverlayState.gif = false;
        }
    }
}
