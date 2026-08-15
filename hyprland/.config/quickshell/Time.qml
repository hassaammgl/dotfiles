pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property date date: clock.date
    readonly property string hour: Qt.formatDateTime(clock.date, "hh")
    readonly property string minute: Qt.formatDateTime(clock.date, "mm")
    readonly property string ampm: Qt.formatDateTime(clock.date, "AP")
    readonly property string weekday: Qt.formatDateTime(clock.date, "ddd")
    readonly property string day: Qt.formatDateTime(clock.date, "d")
    readonly property string month: Qt.formatDateTime(clock.date, "MMM")
    readonly property string vertical: `${hour}\n${minute}\n${ampm}`
    readonly property string horizontal: Qt.formatDateTime(clock.date, "ddd  hh:mm AP")
    readonly property string altVertical: `${weekday}\n${day}\n${month}`
    readonly property string altHorizontal: Qt.formatDateTime(clock.date, "dd MMM yyyy")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
