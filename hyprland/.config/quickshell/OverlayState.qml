pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property bool launcher: false
    property bool power: false
    property bool wallpaper: false

    function toggleLauncher(): void {
        power = false;
        wallpaper = false;
        launcher = !launcher;
    }

    function togglePower(): void {
        launcher = false;
        wallpaper = false;
        power = !power;
    }

    function toggleWallpaper(): void {
        launcher = false;
        power = false;
        wallpaper = !wallpaper;
    }

    function close(): void {
        launcher = false;
        power = false;
        wallpaper = false;
    }
}
