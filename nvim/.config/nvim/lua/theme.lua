-- Colorscheme lives in plugins/ui.lua (Catppuccin).
-- This module stays as a tiny helper for any leftover callers.
local M = {}

function M.colors()
  local ok, palettes = pcall(require, "catppuccin.palettes")
  if ok then
    local p = palettes.get_palette("mocha")
    return {
      background = p.base,
      foreground = p.text,
      color0 = p.surface0,
      color1 = p.red,
      color2 = p.green,
      color3 = p.yellow,
      color4 = p.blue,
      color5 = p.mauve,
      color6 = p.peach,
      color7 = p.subtext1,
      color8 = p.overlay0,
    }
  end
  return {
    background = "#1e1e2e",
    foreground = "#cdd6f4",
    color0 = "#313244",
    color1 = "#f38ba8",
    color2 = "#a6e3a1",
    color3 = "#f9e2af",
    color4 = "#89b4fa",
    color5 = "#cba6f7",
    color6 = "#fab387",
    color7 = "#bac2de",
    color8 = "#6c7086",
  }
end

function M.setup()
  -- colorscheme is applied by the catppuccin plugin (lazy = false)
end

return M
