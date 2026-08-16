import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    IpcHandler {
        target: "lock"

        function lock(): void {
            LockState.lock();
        }
    }

    WlSessionLock {
        locked: LockState.locked

        WlSessionLockSurface {
            color: Colors.background

            readonly property string wall: `file://${Quickshell.env("HOME")}/Pictures/Wallpapers/current`

            Image {
                anchors.fill: parent
                source: wall
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.background, 0.62)
            }

            Column {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -24
                spacing: 28
                width: Math.min(420, parent.width - 64)

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ""
                        color: Colors.accent
                        font.family: Colors.fontFamily
                        font.pixelSize: 22
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${Time.hour}:${Time.minute}`
                        color: Colors.foreground
                        font.family: Colors.fontFamily
                        font.pixelSize: 72
                        font.weight: Font.DemiBold
                        renderType: Text.NativeRendering
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.ampm
                        color: Colors.accent
                        font.family: Colors.fontFamily
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        font.capitalization: Font.AllUppercase
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.longDate
                        color: Colors.color8
                        font.family: Colors.fontFamily
                        font.pixelSize: 14
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(360, parent.width)
                    height: 48
                    radius: 24
                    color: Qt.alpha(Colors.color0, 0.72)
                    border.width: 1
                    border.color: Qt.alpha(LockState.showFailure ? Colors.color1 : Colors.accent, password.activeFocus ? 0.7 : 0.28)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: ""
                            color: LockState.showFailure ? Colors.color1 : Colors.accent
                            font.family: Colors.fontFamily
                            font.pixelSize: 14
                        }

                        TextField {
                            id: password
                            Layout.fillWidth: true
                            placeholderText: "password"
                            color: Colors.foreground
                            placeholderTextColor: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 15
                            background: Item {}
                            echoMode: LockState.reveal ? TextInput.Normal : TextInput.Password
                            passwordCharacter: "•"
                            passwordMaskDelay: 0
                            enabled: !LockState.unlockInProgress
                            focus: true
                            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                            onTextChanged: LockState.currentText = text
                            onAccepted: LockState.tryUnlock()

                            Connections {
                                target: LockState
                                function onCurrentTextChanged(): void {
                                    if (password.text !== LockState.currentText)
                                        password.text = LockState.currentText;
                                }
                                function onLockedChanged(): void {
                                    if (LockState.locked)
                                        password.forceActiveFocus();
                                }
                            }
                        }

                        Text {
                            text: LockState.reveal ? "" : ""
                            color: Colors.color8
                            font.family: Colors.fontFamily
                            font.pixelSize: 14
                            Layout.preferredWidth: 22
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    LockState.reveal = !LockState.reveal;
                                    password.forceActiveFocus();
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: LockState.showFailure
                    text: "wrong password"
                    color: Colors.color1
                    font.family: Colors.fontFamily
                    font.pixelSize: 13
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 36
                text: Quickshell.env("USER")
                color: Colors.color8
                font.family: Colors.fontFamily
                font.pixelSize: 12
            }
        }
    }
}
