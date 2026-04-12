local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Window appearance (matching Kitty transparency and polish)
config.window_background_opacity = 0.85
config.text_background_opacity = 0.85
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Primary integration: Autostart Tmux and attach to 'main' session
config.default_prog = { 'tmux', 'new-session', '-A', '-s', 'main' }

-- Setup multiplexer workaround: Trigger independent isolated Tmux process to spawn 
-- completely fresh sessions instead of repeating the main hook!
config.keys = {
  {
    key = 'T',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SpawnCommandInNewTab {
      args = { 'tmux', 'new-session' },
    },
  },
}

return config
