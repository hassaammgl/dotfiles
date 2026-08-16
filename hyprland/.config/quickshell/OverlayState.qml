pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property bool launcher: false
    property bool power: false
    property bool wallpaper: false
    property bool notifs: false
    property bool keybinds: false

    function toggleLauncher(): void {
        power = false;
        wallpaper = false;
        notifs = false;
        keybinds = false;
        launcher = !launcher;
    }

    function togglePower(): void {
        launcher = false;
        wallpaper = false;
        notifs = false;
        keybinds = false;
        power = !power;
    }

    function toggleWallpaper(): void {
        launcher = false;
        power = false;
        notifs = false;
        keybinds = false;
        wallpaper = !wallpaper;
    }

    function toggleNotifs(): void {
        launcher = false;
        power = false;
        wallpaper = false;
        keybinds = false;
        notifs = !notifs;
    }

    function toggleKeybinds(): void {
        launcher = false;
        power = false;
        wallpaper = false;
        notifs = false;
        keybinds = !keybinds;
    }

    function close(): void {
        launcher = false;
        power = false;
        wallpaper = false;
        notifs = false;
        keybinds = false;
    }
}
