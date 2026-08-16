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
    property bool clipboard: false
    property bool emoji: false
    property bool clipboardDelete: false
    property bool gif: false

    function close(): void {
        launcher = false;
        power = false;
        wallpaper = false;
        notifs = false;
        keybinds = false;
        clipboard = false;
        emoji = false;
        clipboardDelete = false;
        gif = false;
    }

    function toggleLauncher(): void {
        if (launcher)
            close();
        else
            showLauncher();
    }

    function showLauncher(): void {
        close();
        launcher = true;
    }

    function togglePower(): void {
        if (power)
            close();
        else
            showPower();
    }

    function showPower(): void {
        close();
        power = true;
    }

    function toggleWallpaper(): void {
        if (wallpaper)
            close();
        else
            showWallpaper();
    }

    function showWallpaper(): void {
        close();
        wallpaper = true;
    }

    function toggleNotifs(): void {
        if (notifs)
            close();
        else
            showNotifs();
    }

    function showNotifs(): void {
        close();
        notifs = true;
    }

    function toggleKeybinds(): void {
        if (keybinds)
            close();
        else
            showKeybinds();
    }

    function showKeybinds(): void {
        close();
        keybinds = true;
    }

    function toggleClipboard(del: bool): void {
        if (clipboard && clipboardDelete === del)
            close();
        else
            showClipboard(del);
    }

    function showClipboard(del: bool): void {
        close();
        clipboardDelete = del;
        clipboard = true;
    }

    function toggleEmoji(): void {
        if (emoji)
            close();
        else
            showEmoji();
    }

    function showEmoji(): void {
        close();
        emoji = true;
    }

    function toggleGif(): void {
        if (gif)
            close();
        else
            showGif();
    }

    function showGif(): void {
        close();
        gif = true;
    }
}
