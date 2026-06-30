hl.bind("SUPER + Space", hl.dsp.exec_cmd("rofi -show drun"))

hl.bind(kbSession, hl.dsp.exec_cmd("wlogout"))
hl.bind(kbLock, hl.dsp.exec_cmd("hyprlock"))

hl.bind("SUPER + F7", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("SUPER + F6", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

hl.bind("CTRL + SUPER + Space", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("CTRL + SUPER + Equal", hl.dsp.exec_cmd("playerctl next"),      { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),      { locked = true })
hl.bind("CTRL + SUPER + Minus", hl.dsp.exec_cmd("playerctl previous"),  { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),  { locked = true })
hl.bind("XF86AudioStop",        hl.dsp.exec_cmd("playerctl stop"),      { locked = true })

for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind("CTRL + SUPER + " .. key, hl.dsp.focus({ workspace = 10 + i }))
    hl.bind("CTRL + SUPER + ALT + " .. key, hl.dsp.window.move({ workspace = 10 + i }))
end

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(kbPrevWs, hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind(kbNextWs, hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + Page_Up",   hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })

hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "e-10" }))
hl.bind("CTRL + SUPER + mouse_up",   hl.dsp.focus({ workspace = "e+10" }))

hl.bind(kbToggleSpecialWs, hl.dsp.workspace.toggle_special("special"))

hl.bind("SUPER + ALT + Page_Up",   hl.dsp.window.move({ workspace = "e-1" }), { repeating = true })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + ALT + mouse_up",   hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("CTRL + SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + left",  hl.dsp.window.move({ workspace = "e-1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + up",   hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + SUPER + SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }))

hl.bind(kbWindowGroupCycleNext, hl.dsp.exec_cmd("hyprctl dispatch cyclenext"), { repeating = true })
hl.bind(kbWindowGroupCyclePrev, hl.dsp.exec_cmd("hyprctl dispatch cyclenext prev"), { repeating = true })
hl.bind("CTRL + ALT + Tab",             hl.dsp.exec_cmd("hyprctl dispatch changegroupactive f"), { repeating = true })
hl.bind("CTRL + SHIFT + ALT + Tab",     hl.dsp.exec_cmd("hyprctl dispatch changegroupactive b"), { repeating = true })
hl.bind(kbToggleGroup,                  hl.dsp.exec_cmd("hyprctl dispatch togglegroup"))
hl.bind(kbUngroup,                      hl.dsp.exec_cmd("hyprctl dispatch moveoutofgroup"))
hl.bind("SUPER + SHIFT + Comma",        hl.dsp.exec_cmd("hyprctl dispatch lockactivegroup toggle"))

hl.bind("SUPER + left",  hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

hl.bind("SUPER + Minus",       hl.dsp.exec_cmd("hyprctl dispatch resizeactive -10% 0"),  { repeating = true })
hl.bind("SUPER + Equal",       hl.dsp.exec_cmd("hyprctl dispatch resizeactive 10% 0"),   { repeating = true })
hl.bind("SUPER + SHIFT + Minus", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -10%"),  { repeating = true })
hl.bind("SUPER + SHIFT + Equal", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 10%"),   { repeating = true })
hl.bind("SUPER + ALT + left",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive -10% 0"),  { repeating = true })
hl.bind("SUPER + ALT + right",   hl.dsp.exec_cmd("hyprctl dispatch resizeactive 10% 0"),   { repeating = true })
hl.bind("SUPER + ALT + up",      hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -10%"),  { repeating = true })
hl.bind("SUPER + ALT + down",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 10%"),   { repeating = true })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("CTRL + SUPER + Backslash",     hl.dsp.exec_cmd("hyprctl dispatch centerwindow 1"))
hl.bind("CTRL + SUPER + ALT + Backslash", hl.dsp.exec_cmd("hyprctl dispatch resizeactive exact 55% 70%; hyprctl dispatch centerwindow 1"))

hl.bind(kbPinWindow,              hl.dsp.exec_cmd("hyprctl dispatch pin"))
hl.bind(kbWindowFullscreen,       hl.dsp.exec_cmd("hyprctl dispatch fullscreen 0"))
hl.bind(kbWindowBorderedFullscreen, hl.dsp.exec_cmd("hyprctl dispatch fullscreen 1"))
hl.bind(kbToggleWindowFloating,   hl.dsp.exec_cmd("hyprctl dispatch togglefloating"))
hl.bind(kbCloseWindow,            hl.dsp.window.close())

hl.bind(kbSystemMonitor, hl.dsp.workspace.toggle_special("sysmon"))
hl.bind(kbMusic,         hl.dsp.workspace.toggle_special("music"))
hl.bind(kbCommunication, hl.dsp.workspace.toggle_special("communication"))
hl.bind(kbTodo,          hl.dsp.workspace.toggle_special("todo"))

hl.bind(kbTerminal, hl.dsp.exec_cmd(terminal))
hl.bind(kbBrowser,  hl.dsp.exec_cmd(browser))
hl.bind(kbEditor,   hl.dsp.exec_cmd(editor))
hl.bind("SUPER + G", hl.dsp.exec_cmd("github-desktop"))
hl.bind(kbFileExplorer,   hl.dsp.exec_cmd(fileExplorer))
hl.bind("SUPER + ALT + E",   hl.dsp.exec_cmd("nemo"))
hl.bind("CTRL + ALT + Escape", hl.dsp.exec_cmd("qps"))
hl.bind("CTRL + ALT + V",      hl.dsp.exec_cmd("pavucontrol"))

hl.bind("Print",   hl.dsp.exec_cmd("grim - | wl-copy"), { locked = true })
hl.bind("SUPER + SHIFT + S",       hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SUPER + SHIFT + ALT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SUPER + ALT + R",         hl.dsp.exec_cmd("wf-recorder --audio -f ~/Videos/recording_$(date +%s).mp4"))
hl.bind("CTRL + ALT + R",          hl.dsp.exec_cmd("wf-recorder -f ~/Videos/recording_$(date +%s).mp4"))
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd("wf-recorder -g \"$(slurp)\" -f ~/Videos/recording_$(date +%s).mp4"))
hl.bind("SUPER + SHIFT + C",       hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("ALT + W",          hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh"))
hl.bind("SHIFT + ALT + W",  hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper.sh next"))

hl.bind("XF86AudioMicMute",                  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute",                     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("SUPER + SHIFT + M",                 hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioRaiseVolume",              hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. volumeStep .. "%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",              hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. volumeStep .. "%-"), { locked = true, repeating = true })
hl.bind("SUPER + F3", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. volumeStep .. "%+"), { locked = true, repeating = true })
hl.bind("SUPER + F2",  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. volumeStep .. "%-"), { locked = true, repeating = true })
hl.bind("SUPER + F1",  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), { locked = true })

hl.bind("SUPER + V",           hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind("SUPER + ALT + V",     hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist delete"))
hl.bind("SUPER + Period",      hl.dsp.exec_cmd("rofi -show emoji"))
hl.bind("CTRL + SHIFT + ALT + V", hl.dsp.exec_cmd("sleep 0.5s && ydotool type -d 1 \"$(cliphist list | head -1 | cliphist decode)\""), { locked = true })

hl.bind("ALT + H", hl.dsp.exec_cmd("rofi -dmenu -p 'Keybinds' -theme-str 'window{width:50%;}' < ~/.config/hypr/scripts/keybinds.txt"))

hl.bind("SUPER + ALT + f12", hl.dsp.exec_cmd("notify-send -u low -i dialog-information-symbolic 'Test notification' \"Here's a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!\" -a 'Shell' -A \"Test1=I got it!\" -A \"Test2=Another action\""))
