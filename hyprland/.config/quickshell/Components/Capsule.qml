import QtQuick
import ".."

Rectangle {
    id: root

    property bool active: false

    radius: Theme.r.md
    color: active ? Theme.colors.accentSoft : Theme.colors.surface
    border.width: 1
    border.color: active ? Theme.withAlpha(Theme.colors.accent, 0.45) : Theme.colors.borderSubtle
}
