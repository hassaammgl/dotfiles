import QtQuick
import ".."

Rectangle {
    id: root

    property real alpha: 1
    property bool outlined: true
    property int radiusSize: Theme.r.md

    radius: radiusSize
    color: Theme.withAlpha(Theme.colors.surface, alpha)
    border.width: outlined ? 1 : 0
    border.color: Theme.colors.border
}
