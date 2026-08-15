pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property color background: pal.background
    readonly property color foreground: pal.foreground
    readonly property color cursor: pal.cursor
    readonly property color color0: pal.color0
    readonly property color color1: pal.color1
    readonly property color color2: pal.color2
    readonly property color color3: pal.color3
    readonly property color color4: pal.color4
    readonly property color color5: pal.color5
    readonly property color color6: pal.color6
    readonly property color color7: pal.color7
    readonly property color color8: pal.color8
    readonly property color color9: pal.color9
    readonly property color color10: pal.color10
    readonly property color color11: pal.color11
    readonly property color color12: pal.color12
    readonly property color color13: pal.color13
    readonly property color color14: pal.color14
    readonly property color color15: pal.color15

    readonly property color surface: Qt.alpha(color0, 0.72)
    readonly property color accent: color4
    readonly property color secondary: color12
    readonly property color tertiary: color4

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    FileView {
        path: `${Quickshell.env("HOME")}/.cache/wallust/quickshell.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: {}

        JsonAdapter {
            id: pal
            property string background: "#141414"
            property string foreground: "#FBF9F5"
            property string cursor: "#A4A19E"
            property string color0: "#3F3F3F"
            property string color1: "#484848"
            property string color2: "#676463"
            property string color3: "#827F7B"
            property string color4: "#967772"
            property string color5: "#827F78"
            property string color6: "#B6B2AA"
            property string color7: "#F1EEE9"
            property string color8: "#A8A7A3"
            property string color9: "#4C4C4C"
            property string color10: "#757270"
            property string color11: "#847D77"
            property string color12: "#B98B84"
            property string color13: "#AEA9A0"
            property string color14: "#F3EEE3"
            property string color15: "#F1EEE9"
        }
    }
}
