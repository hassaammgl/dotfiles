import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    readonly property int maxVisible: 5
    readonly property int cardW: 392

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;
            const vals = server.trackedNotifications.values;
            if (vals.length > root.maxVisible)
                vals[0].expire();
        }
    }

    function timeoutFor(notif): int {
        if (!notif)
            return 5000;
        if (notif.expireTimeout > 0)
            return notif.expireTimeout;
        if (notif.expireTimeout === 0)
            return 0;
        switch (notif.urgency) {
        case NotificationUrgency.Critical:
            return 0;
        case NotificationUrgency.Low:
            return 3500;
        default:
            return 5000;
        }
    }

    function accentFor(notif): color {
        if (!notif)
            return Colors.accent;
        switch (notif.urgency) {
        case NotificationUrgency.Critical:
            return Colors.secondary;
        case NotificationUrgency.Low:
            return Colors.color8;
        default:
            return Colors.accent;
        }
    }

    function tagFor(notif): string {
        if (!notif)
            return "MSG";
        switch (notif.urgency) {
        case NotificationUrgency.Critical:
            return "CRIT";
        case NotificationUrgency.Low:
            return "LOW";
        default:
            return "MSG";
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: true
            color: "transparent"
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true
            WlrLayershell.namespace: "quickshell-notifications"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                right: true
            }

            margins {
                top: 14
                right: 14
            }

            implicitWidth: root.cardW
            implicitHeight: Math.max(1, list.contentHeight)

            ListView {
                id: list
                anchors.top: parent.top
                anchors.right: parent.right
                width: root.cardW
                height: contentHeight
                spacing: 10
                clip: false
                interactive: false
                orientation: ListView.Vertical
                verticalLayoutDirection: ListView.BottomToTop
                model: server.trackedNotifications

                delegate: Item {
                    id: wrap
                    required property var modelData
                    readonly property var notif: modelData
                    readonly property string appName: notif ? (notif.appName || "SYSTEM") : ""
                    readonly property string summary: notif ? notif.summary : ""
                    readonly property string body: notif ? notif.body : ""
                    readonly property var actions: notif ? notif.actions : []
                    readonly property var urgency: notif ? notif.urgency : NotificationUrgency.Normal
                    readonly property string image: notif && notif.image ? notif.image : ""
                    readonly property string appIcon: notif && notif.appIcon ? notif.appIcon : ""

                    width: root.cardW
                    implicitHeight: card.implicitHeight
                    height: implicitHeight
                    visible: notif !== null && notif !== undefined

                    property bool shown: false
                    property bool dismissing: false
                    property real dragX: 0
                    property real life: 1
                    property real enterOff: shown ? 0 : 52
                    readonly property color accent: root.accentFor(notif)
                    readonly property int timeoutMs: root.timeoutFor(notif)
                    readonly property bool hasImage: image.length > 0
                    readonly property bool hasIcon: appIcon.length > 0
                    readonly property string stamp: {
                        const d = new Date();
                        return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
                    }

                    opacity: (shown ? 1 : 0) * Math.max(0, 1 - wrap.dragX / 170)

                    function fadeOut(): void {
                        if (!shown)
                            return;
                        dismissing = false;
                        shown = false;
                        fadeFinish.restart();
                    }

                    function dismissCard(): void {
                        if (!shown)
                            return;
                        dismissing = true;
                        shown = false;
                        fadeFinish.restart();
                    }

                    NumberAnimation on dragX {
                        id: snapBack
                        duration: 160
                        easing.type: Easing.OutCubic
                        running: false
                    }

                    Timer {
                        id: fadeFinish
                        interval: 200
                        repeat: false
                        onTriggered: {
                            if (!wrap.notif)
                                return;
                            if (wrap.dismissing)
                                wrap.notif.dismiss();
                            else
                                wrap.notif.expire();
                        }
                    }

                    NumberAnimation {
                        id: drain
                        target: wrap
                        property: "life"
                        from: 1
                        to: 0
                        duration: Math.max(1, wrap.timeoutMs)
                        running: wrap.shown && wrap.timeoutMs > 0
                        paused: hover.hovered || wrap.dragX > 8
                        onFinished: wrap.fadeOut()
                    }

                    Rectangle {
                        id: card
                        width: root.cardW
                        x: wrap.enterOff + wrap.dragX
                        implicitHeight: inner.implicitHeight + 20
                        height: implicitHeight
                        radius: 2
                        color: Colors.background
                        border.width: 1
                        border.color: wrap.accent
                        clip: true

                        Rectangle {
                            id: rail
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 3
                            color: wrap.accent

                            SequentialAnimation on opacity {
                                running: wrap.urgency === NotificationUrgency.Critical && wrap.shown
                                loops: Animation.Infinite
                                NumberAnimation {
                                    from: 1
                                    to: 0.25
                                    duration: 420
                                }
                                NumberAnimation {
                                    from: 0.25
                                    to: 1
                                    duration: 420
                                }
                            }
                        }

                        Repeater {
                            model: 4
                            Rectangle {
                                required property int index
                                width: 12
                                height: 2
                                color: wrap.accent
                                x: index % 2 === 0 ? 6 : card.width - 18
                                y: index < 2 ? 5 : card.height - 7
                            }
                        }
                        Repeater {
                            model: 4
                            Rectangle {
                                required property int index
                                width: 2
                                height: 12
                                color: wrap.accent
                                x: index % 2 === 0 ? 6 : card.width - 8
                                y: index < 2 ? 5 : card.height - 17
                            }
                        }

                        Column {
                            id: inner
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.leftMargin: 16
                            anchors.rightMargin: 12
                            anchors.topMargin: 10
                            spacing: 8

                            RowLayout {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: "⟨ INCOMING ⟩"
                                    color: wrap.accent
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                    font.letterSpacing: 1.2
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: root.tagFor(wrap.notif)
                                    color: wrap.accent
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                    font.letterSpacing: 1.4
                                }

                                Text {
                                    text: wrap.stamp
                                    color: Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "✕"
                                    color: closeHover.containsMouse ? Colors.foreground : Colors.color8
                                    font.family: Colors.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true

                                    MouseArea {
                                        id: closeHover
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: wrap.dismissCard()
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 10

                                Item {
                                    Layout.preferredWidth: 42
                                    Layout.preferredHeight: 42

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 2
                                        color: Qt.alpha(wrap.accent, 0.18)
                                        border.width: 1
                                        border.color: Qt.alpha(wrap.accent, 0.55)

                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            visible: wrap.hasImage
                                            source: wrap.hasImage ? wrap.image : ""
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                        }

                                        IconImage {
                                            anchors.centerIn: parent
                                            visible: !wrap.hasImage && wrap.hasIcon
                                            implicitSize: 28
                                            source: wrap.hasIcon ? Quickshell.iconPath(wrap.appIcon) : ""
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !wrap.hasImage && !wrap.hasIcon
                                            text: (wrap.appName || "?").charAt(0).toUpperCase()
                                            color: wrap.accent
                                            font.family: Colors.fontFamily
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        width: parent.width
                                        text: wrap.appName.toUpperCase()
                                        color: Colors.color8
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 10
                                        font.letterSpacing: 1.1
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        visible: wrap.summary.length > 0
                                        text: wrap.summary
                                        color: Colors.foreground
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        visible: wrap.body.length > 0
                                        text: wrap.body
                                        color: Colors.color8
                                        font.family: Colors.fontFamily
                                        font.pixelSize: 11
                                        textFormat: Text.StyledText
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 4
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Flow {
                                width: parent.width
                                spacing: 6
                                visible: wrap.actions.length > 0

                                Repeater {
                                    model: wrap.actions

                                    delegate: Rectangle {
                                        required property var modelData
                                        implicitWidth: actionLabel.implicitWidth + 16
                                        implicitHeight: 22
                                        radius: 1
                                        color: actionHover.containsMouse ? Qt.alpha(wrap.accent, 0.4) : Qt.alpha(wrap.accent, 0.12)
                                        border.width: 1
                                        border.color: wrap.accent

                                        Text {
                                            id: actionLabel
                                            anchors.centerIn: parent
                                            text: modelData.text
                                            color: Colors.foreground
                                            font.family: Colors.fontFamily
                                            font.pixelSize: 10
                                            font.letterSpacing: 0.6
                                        }

                                        MouseArea {
                                            id: actionHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                modelData.invoke();
                                                wrap.dismissCard();
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 2
                            color: Qt.alpha(wrap.accent, 0.18)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * wrap.life
                                visible: wrap.timeoutMs > 0
                                color: wrap.accent
                            }
                        }
                    }

                    HoverHandler {
                        id: hover
                    }

                    TapHandler {
                        acceptedButtons: Qt.MiddleButton | Qt.RightButton
                        onTapped: wrap.dismissCard()
                    }

                    DragHandler {
                        target: null
                        xAxis.enabled: true
                        yAxis.enabled: false
                        onTranslationChanged: wrap.dragX = Math.max(0, translation.x)
                        onActiveChanged: {
                            if (active)
                                return;
                            if (wrap.dragX > 72)
                                wrap.dismissCard();
                            else {
                                snapBack.to = 0;
                                snapBack.from = wrap.dragX;
                                snapBack.start();
                            }
                        }
                    }

                    Behavior on enterOff {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Component.onCompleted: shown = true
                }
            }
        }
    }
}
