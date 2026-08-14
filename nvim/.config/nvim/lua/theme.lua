local M = {}

local path = vim.fn.expand("~/.cache/wallust/nvim.lua")

local fallback = {
  background = "#181515",
  foreground = "#FFEFE1",
  cursor = "#A4A4AE",
  color0 = "#43403F",
  color1 = "#7C5E50",
  color2 = "#636E82",
  color3 = "#817F78",
  color4 = "#9E7E75",
  color5 = "#7E818C",
  color6 = "#BF9C7F",
  color7 = "#F6DFCC",
  color8 = "#AD9C8E",
  color9 = "#936A57",
  color10 = "#717F9A",
  color11 = "#87857A",
  color12 = "#AC7567",
  color13 = "#9FA3B3",
  color14 = "#FFD0A9",
  color15 = "#F6DFCC",
}

local function load_colors()
  if vim.uv.fs_stat(path) then
    local ok, colors = pcall(dofile, path)
    if ok and type(colors) == "table" and colors.background then
      return colors
    end
  end
  return fallback
end

local function hi(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

function M.apply()
  local c = load_colors()
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "wallust"

  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = c["color" .. i]
  end

  hi("Normal", { fg = c.foreground, bg = c.background })
  hi("NormalNC", { fg = c.foreground, bg = c.background })
  hi("NormalFloat", { fg = c.foreground, bg = c.color0 })
  hi("FloatBorder", { fg = c.color4, bg = c.color0 })
  hi("FloatTitle", { fg = c.color4, bg = c.color0, bold = true })
  hi("WinSeparator", { fg = c.color8 })
  hi("LineNr", { fg = c.color8 })
  hi("CursorLineNr", { fg = c.color4, bold = true })
  hi("CursorLine", { bg = c.color0 })
  hi("CursorColumn", { bg = c.color0 })
  hi("ColorColumn", { bg = c.color0 })
  hi("SignColumn", { bg = c.background })
  hi("Folded", { fg = c.color8, bg = c.color0 })
  hi("FoldColumn", { fg = c.color8, bg = c.background })
  hi("VertSplit", { fg = c.color8 })
  hi("Visual", { bg = c.color4, fg = c.background })
  hi("Search", { bg = c.color3, fg = c.background })
  hi("IncSearch", { bg = c.color4, fg = c.background })
  hi("CurSearch", { bg = c.color4, fg = c.background })
  hi("MatchParen", { fg = c.color6, bold = true })
  hi("Cursor", { fg = c.background, bg = c.cursor })
  hi("TermCursor", { fg = c.background, bg = c.cursor })

  hi("Comment", { fg = c.color8, italic = true })
  hi("String", { fg = c.color2 })
  hi("Character", { fg = c.color2 })
  hi("Number", { fg = c.color6 })
  hi("Float", { fg = c.color6 })
  hi("Boolean", { fg = c.color6 })
  hi("Constant", { fg = c.color6 })
  hi("Identifier", { fg = c.foreground })
  hi("Function", { fg = c.color4 })
  hi("Statement", { fg = c.color5 })
  hi("Keyword", { fg = c.color5 })
  hi("Conditional", { fg = c.color5 })
  hi("Repeat", { fg = c.color5 })
  hi("Operator", { fg = c.color7 })
  hi("PreProc", { fg = c.color3 })
  hi("Type", { fg = c.color3 })
  hi("Special", { fg = c.color6 })
  hi("Delimiter", { fg = c.color7 })
  hi("Title", { fg = c.color4, bold = true })
  hi("Todo", { fg = c.color3, bold = true })
  hi("Error", { fg = c.color1, bold = true })
  hi("ErrorMsg", { fg = c.color1 })
  hi("WarningMsg", { fg = c.color3 })
  hi("ModeMsg", { fg = c.color4, bold = true })
  hi("MoreMsg", { fg = c.color2 })
  hi("Question", { fg = c.color4 })
  hi("NonText", { fg = c.color8 })
  hi("Whitespace", { fg = c.color8 })
  hi("SpecialKey", { fg = c.color8 })
  hi("Directory", { fg = c.color4 })
  hi("Added", { fg = c.color2 })
  hi("Changed", { fg = c.color4 })
  hi("Removed", { fg = c.color1 })

  hi("StatusLine", { fg = c.foreground, bg = c.color0 })
  hi("StatusLineNC", { fg = c.color8, bg = c.color0 })
  hi("TabLine", { fg = c.color8, bg = c.color0 })
  hi("TabLineSel", { fg = c.background, bg = c.color4, bold = true })
  hi("TabLineFill", { bg = c.background })
  hi("WinBar", { fg = c.foreground, bg = c.background })
  hi("WinBarNC", { fg = c.color8, bg = c.background })
  hi("Pmenu", { fg = c.foreground, bg = c.color0 })
  hi("PmenuSel", { fg = c.background, bg = c.color4 })
  hi("PmenuSbar", { bg = c.color0 })
  hi("PmenuThumb", { bg = c.color8 })
  hi("WildMenu", { fg = c.background, bg = c.color4 })

  hi("DiffAdd", { fg = c.color2, bg = c.color0 })
  hi("DiffChange", { fg = c.color4, bg = c.color0 })
  hi("DiffDelete", { fg = c.color1, bg = c.color0 })
  hi("DiffText", { fg = c.color6, bg = c.color0, bold = true })

  hi("DiagnosticError", { fg = c.color1 })
  hi("DiagnosticWarn", { fg = c.color3 })
  hi("DiagnosticInfo", { fg = c.color4 })
  hi("DiagnosticHint", { fg = c.color2 })
  hi("DiagnosticOk", { fg = c.color2 })

  hi("GitSignsAdd", { fg = c.color2 })
  hi("GitSignsChange", { fg = c.color4 })
  hi("GitSignsDelete", { fg = c.color1 })

  hi("NvimTreeNormal", { fg = c.foreground, bg = c.color0 })
  hi("NvimTreeFolderName", { fg = c.color4 })
  hi("NvimTreeOpenedFolderName", { fg = c.color6, bold = true })
  hi("NvimTreeRootFolder", { fg = c.color5, bold = true })
  hi("NvimTreeGitDirty", { fg = c.color3 })
  hi("NvimTreeGitNew", { fg = c.color2 })
  hi("NvimTreeGitDeleted", { fg = c.color1 })

  local ts = {
    ["@comment"] = { fg = c.color8, italic = true },
    ["@string"] = { fg = c.color2 },
    ["@character"] = { fg = c.color2 },
    ["@number"] = { fg = c.color6 },
    ["@boolean"] = { fg = c.color6 },
    ["@constant"] = { fg = c.color6 },
    ["@variable"] = { fg = c.foreground },
    ["@variable.builtin"] = { fg = c.color1 },
    ["@variable.parameter"] = { fg = c.color7 },
    ["@property"] = { fg = c.color6 },
    ["@field"] = { fg = c.color6 },
    ["@function"] = { fg = c.color4 },
    ["@function.builtin"] = { fg = c.color12 },
    ["@function.method"] = { fg = c.color4 },
    ["@keyword"] = { fg = c.color5 },
    ["@keyword.function"] = { fg = c.color5 },
    ["@keyword.return"] = { fg = c.color5 },
    ["@keyword.import"] = { fg = c.color3 },
    ["@type"] = { fg = c.color3 },
    ["@type.builtin"] = { fg = c.color3 },
    ["@constructor"] = { fg = c.color3 },
    ["@operator"] = { fg = c.color7 },
    ["@punctuation"] = { fg = c.color7 },
    ["@punctuation.bracket"] = { fg = c.color8 },
    ["@tag"] = { fg = c.color5 },
    ["@tag.attribute"] = { fg = c.color4 },
    ["@markup.heading"] = { fg = c.color4, bold = true },
    ["@markup.link"] = { fg = c.color4, underline = true },
  }
  for group, spec in pairs(ts) do
    hi(group, spec)
  end
end

function M.setup()
  M.apply()

  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("wallust_theme", { clear = true }),
    callback = M.apply,
  })

  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")
  local watcher = vim.uv.new_fs_event()
  if watcher then
    watcher:start(dir, {}, function(_, filename)
      if filename == "nvim.lua" then
        vim.schedule(M.apply)
      end
    end)
  end
end

return M
