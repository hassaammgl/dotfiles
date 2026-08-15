pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property bool launcher: false
    property bool power: false

    function toggleLauncher(): void {
        power = false;
        launcher = !launcher;
    }

    function togglePower(): void {
        launcher = false;
        power = !power;
    }

    function close(): void {
        launcher = false;
        power = false;
    }
}
