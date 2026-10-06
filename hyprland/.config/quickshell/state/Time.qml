pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property date date: clock.date
    readonly property string hour: {
        const n = parseInt(Qt.formatDateTime(clock.date, "HH"), 10);
        const h = n % 12;
        const d = h === 0 ? 12 : h;
        return d < 10 ? `0${d}` : String(d);
    }
    readonly property string minute: Qt.formatDateTime(clock.date, "mm")
    readonly property string ampm: Qt.formatDateTime(clock.date, "ap")
    readonly property string weekday: Qt.formatDateTime(clock.date, "ddd")
    readonly property string day: Qt.formatDateTime(clock.date, "d")
    readonly property string month: Qt.formatDateTime(clock.date, "MMM")
    readonly property string vertical: `${hour}\n${minute}\n${ampm}`
    readonly property string horizontal: Qt.formatDateTime(clock.date, "ddd  h:mm ap")
    readonly property string altVertical: `${weekday}\n${day}\n${month}`
    readonly property string altHorizontal: Qt.formatDateTime(clock.date, "dd MMM yyyy")
    readonly property string longDate: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
