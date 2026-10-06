import Quickshell
import QtQuick

// Caelestia-style mascot: put GIF/PNG in ~/.config/quickshell/assets/
Item {
    id: root

    property string fileName: "media.gif"
    property real maxH: 180
    property bool playing: true

    readonly property string url: `file://${Quickshell.env("HOME")}/.config/quickshell/assets/${fileName}`
    readonly property bool animated: /\.(gif|webp)$/i.test(fileName)

    implicitWidth: loader.item && loader.item.status === Image.Ready ? Math.min(loader.item.implicitWidth, maxH * 1.25) : 0
    implicitHeight: loader.item && loader.item.status === Image.Ready ? Math.min(loader.item.implicitHeight, maxH) : 0
    visible: implicitWidth > 0
    opacity: visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 180
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: root.animated ? gifComp : pngComp
    }

    Component {
        id: gifComp
        AnimatedImage {
            source: root.url
            fillMode: Image.PreserveAspectFit
            playing: root.playing
            asynchronous: true
            mipmap: true
            cache: true
        }
    }

    Component {
        id: pngComp
        Image {
            source: root.url
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            mipmap: true
            cache: true
        }
    }
}
