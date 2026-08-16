pragma Singleton

import Quickshell
import Quickshell.Services.Pam
import QtQuick

Singleton {
    id: root

    property bool locked: false
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool reveal: false

    onCurrentTextChanged: showFailure = false

    onLockedChanged: {
        if (locked) {
            currentText = "";
            showFailure = false;
            unlockInProgress = false;
            reveal = false;
            OverlayState.close();
        }
    }

    function lock(): void {
        locked = true;
    }

    function tryUnlock(): void {
        if (currentText === "" || unlockInProgress)
            return;
        unlockInProgress = true;
        if (!pam.start()) {
            unlockInProgress = false;
            showFailure = true;
        }
    }

    PamContext {
        id: pam
        configDirectory: `${Quickshell.env("HOME")}/.config/quickshell/pam`
        config: "password.conf"
        user: Quickshell.env("USER")

        onPamMessage: {
            if (responseRequired)
                respond(root.currentText);
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.currentText = "";
                root.locked = false;
            } else {
                root.currentText = "";
                root.showFailure = true;
            }
            root.unlockInProgress = false;
        }

        onError: {
            root.currentText = "";
            root.showFailure = true;
            root.unlockInProgress = false;
        }
    }
}
