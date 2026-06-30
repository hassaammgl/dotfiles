hl.config({
    general = {
        layout = "dwindle",
        allow_tearing = false,
        gaps_workspaces = workspaceGaps,
        gaps_in = windowGapsIn,
        gaps_out = windowGapsOut,
        border_size = windowBorderSize,
        col = {
            active_border = "rgba(c2c1ffe6)",
            inactive_border = "rgba(c8c5d111)",
        },
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },
})
