pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property bool launcher: false
    property bool power: false
    property bool wallpaper: false
    property bool notifs: false

    function toggleLauncher(): void {
        power = false;
        wallpaper = false;
        notifs = false;
        launcher = !launcher;
    }

    function togglePower(): void {
        launcher = false;
        wallpaper = false;
        notifs = false;
        power = !power;
    }

    function toggleWallpaper(): void {
        launcher = false;
        power = false;
        notifs = false;
        wallpaper = !wallpaper;
    }

    function toggleNotifs(): void {
        launcher = false;
        power = false;
        wallpaper = false;
        notifs = !notifs;
    }

    function close(): void {
        launcher = false;
        power = false;
        wallpaper = false;
        notifs = false;
    }
}
