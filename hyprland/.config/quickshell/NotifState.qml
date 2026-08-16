pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property int maxItems: 50
    property var items: []

    function record(notif): void {
        if (!notif)
            return;
        const entry = {
            "nid": `${notif.id}`,
            "appName": notif.appName || "SYSTEM",
            "summary": notif.summary || "",
            "body": notif.body || "",
            "urgency": Number(notif.urgency),
            "image": notif.image || "",
            "appIcon": notif.appIcon || "",
            "time": Date.now()
        };
        const rest = root.items.filter(e => e.nid !== entry.nid);
        root.items = [entry, ...rest].slice(0, root.maxItems);
        adapter.payload = JSON.stringify(root.items);
    }

    function removeAt(index: int): void {
        if (index < 0 || index >= root.items.length)
            return;
        const next = root.items.slice();
        next.splice(index, 1);
        root.items = next;
        adapter.payload = JSON.stringify(root.items);
    }

    function clear(): void {
        root.items = [];
        adapter.payload = "[]";
    }

    function accentFor(entry): color {
        if (!entry)
            return Colors.accent;
        if (entry.urgency === 2)
            return Colors.secondary;
        if (entry.urgency === 0)
            return Colors.color8;
        return Colors.accent;
    }

    function tagFor(entry): string {
        if (!entry)
            return "MSG";
        if (entry.urgency === 2)
            return "CRIT";
        if (entry.urgency === 0)
            return "LOW";
        return "MSG";
    }

    function timeAgo(ms: var): string {
        const t = Number(ms) || 0;
        const d = Math.max(0, Date.now() - t);
        const m = Math.floor(d / 60000);
        if (m < 1)
            return "now";
        if (m < 60)
            return `${m}m`;
        const h = Math.floor(m / 60);
        if (h < 24)
            return `${h}h`;
        return `${Math.floor(h / 24)}d`;
    }

    FileView {
        path: Quickshell.statePath("notif-history.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: {
            try {
                const parsed = JSON.parse(adapter.payload || "[]");
                root.items = Array.isArray(parsed) ? parsed : [];
            } catch (e) {
                root.items = [];
            }
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property string payload: "[]"
        }
    }
}
