local M = {}

M.moods = {
  {
    id = "focus",
    label = "Focus",
    desc = "Deep work — kanagawa dragon",
    colorscheme = "kanagawa",
  },
  {
    id = "energy",
    label = "Energy",
    desc = "Grind mode — tokyonight night",
    colorscheme = "tokyonight-night",
  },
  {
    id = "chill",
    label = "Chill",
    desc = "Late night — rose pine moon",
    colorscheme = "rose-pine-moon",
  },
}

local function theme_path()
  return vim.fn.expand("~/.tmux-theme.conf")
end

local function hl_hex(name, key)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl or not hl[key] then
    return nil
  end
  return string.format("#%06x", hl[key])
end

-- Build tmux colors from the ACTIVE neovim highlights (true match)
local function colors_from_nvim()
  local bg = hl_hex("Normal", "bg") or "#181616"
  local fg = hl_hex("Normal", "fg") or "#c5c9c5"
  local muted = hl_hex("StatusLine", "fg") or hl_hex("Comment", "fg") or "#727169"
  local accent = hl_hex("Function", "fg")
    or hl_hex("DiagnosticInfo", "fg")
    or hl_hex("TabLineSel", "bg")
    or "#8ba4b0"

  return {
    bg = bg,
    fg = fg,
    muted = muted,
    accent = accent,
    accent_fg = bg,
  }
end

function M.write_tmux_theme(t)
  t = t or colors_from_nvim()
  local lines = {
    string.format("set -g status-style \"bg=%s,fg=%s\"", t.bg, t.fg),
    string.format(
      'set -g status-left "#[bg=%s,fg=%s,bold] tmux #S #[default] "',
      t.accent,
      t.accent_fg
    ),
    string.format('set -g status-right "#[fg=%s]%%H:%%M "', t.muted),
    string.format(
      "set -g window-status-current-style \"bg=%s,fg=%s,bold\"",
      t.accent,
      t.accent_fg
    ),
    string.format("set -g window-status-style \"bg=%s,fg=%s\"", t.bg, t.muted),
    string.format("set -g pane-active-border-style \"fg=%s\"", t.accent),
    string.format("set -g pane-border-style \"fg=%s\"", t.muted),
    string.format("set -g message-style \"bg=%s,fg=%s\"", t.accent, t.accent_fg),
    string.format("set -g mode-style \"bg=%s,fg=%s\"", t.accent, t.accent_fg),
  }
  vim.fn.writefile(lines, theme_path())
  return t
end

function M.sync_tmux()
  -- wait a tick so ColorScheme highlights are fully applied
  vim.schedule(function()
    M.write_tmux_theme()
    if not vim.env.TMUX then
      return
    end
    -- apply immediately to running server
    vim.fn.system({ "tmux", "source-file", theme_path() })
    -- refresh clients so bar redraws
    vim.fn.system({ "tmux", "refresh-client", "-S" })
  end)
end

function M.apply(mood)
  vim.cmd.colorscheme(mood.colorscheme)
  vim.g.colors_mood = mood.id
  M.sync_tmux()
  vim.notify(mood.label .. " · " .. mood.desc, vim.log.levels.INFO, { title = "Mood" })
end

function M.pick()
  vim.ui.select(M.moods, {
    prompt = "Mood",
    format_item = function(item)
      return string.format("%s — %s", item.label, item.desc)
    end,
  }, function(item)
    if item then
      M.apply(item)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("mood_tmux_sync", { clear = true }),
    callback = function()
      M.sync_tmux()
    end,
  })

  -- autocmds.lua itself loads on VeryLazy — call sync now (don't wait for another VeryLazy)
  M.sync_tmux()
end

return M
