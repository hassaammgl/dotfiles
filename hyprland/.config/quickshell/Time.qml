pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property date date: clock.date
    readonly property string vertical: Qt.formatDateTime(clock.date, "hh\nmm\nAP")
    readonly property string horizontal: Qt.formatDateTime(clock.date, "ddd  hh:mm AP")
    readonly property string altVertical: Qt.formatDateTime(clock.date, "ddd\ndd\nMMM")
    readonly property string altHorizontal: Qt.formatDateTime(clock.date, "dd MMM yyyy")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
